// 3D City Metaverse Buildings and Staking Rewards Smart Contract
// Developed by 3D Studio office@3dcity.life
// https://3dcity.life
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CityRewardsSC is ReentrancyGuard, Ownable {
    IERC20 public token;

    struct StakingInfo {
        uint256 amountStaked;
        uint256 stakingStartTime;
        uint256 stakingPeriod; // in seconds
        bool hasStaked;
    }

    struct BuildingRewardInfo {
        string buildingName;
        uint8 rewardPower; // 1 for A, 2 for B, 3 for C
    }

    mapping(address => StakingInfo) internal stakingData;
    mapping(address => mapping(string => uint256)) public purchases;
    mapping(address => string[]) private userItems; 
    mapping(string => bool) public whitelistedBuildings;

    mapping(string => BuildingRewardInfo) public buildingRewards; // Building reward info
    mapping(address => uint256) public lastBuildingRewardClaim; // Tracks last time building rewards were claimed by user

    uint256 public rewardPercentage; // For building rewards
    uint256 public stakingPercentage; // For staking rewards
    uint256 private developerDividendsPercentage; 
    uint256 public rewardFrequency;

    uint256 internal constant MIN_REWARD_FREQUENCY = 1 days; 
    uint256 internal constant MAX_REWARD_FREQUENCY = 7 days; 

    uint256 public constant EMERGENCY_WITHDRAW_PENALTY = 30; // 30% penalty
    uint256 public constant PERCENTAGE_DIVISOR = 100;

    string private securityKey; 

    event TokensStaked(address indexed user, uint256 amount, uint256 stakingDays, string buildingName);
    event StakingRewardsClaimed(address indexed user, uint256 rewardAmount); 
    event EmergencyWithdraw(address indexed user, uint256 amountWithdrawn);
    event RewardFrequencyUpdated(uint256 newFrequency);
    event StakingBuildingsUpdated(string[] buildingNames);
    event DeveloperDividendsWithdrawn(uint256 amountWithdrawn);
    event TokenContractUpdated(address newTokenAddress);
    event ContractReset(address indexed owner, uint256 amountWithdrawn);
    event ProxyTransfer(address indexed user, uint256 amount, string itemName);
    event BuildingRewardsClaimed(address indexed user, uint256 rewardAmount);

    constructor(IERC20 _token) Ownable(msg.sender) {
        token = _token;
        rewardPercentage = 10;
        stakingPercentage = 20;
        developerDividendsPercentage = 5;
        rewardFrequency = 1 days;
        securityKey = "defaultKey"; 
    }

    // Modifiers
    modifier validatePercentages() {
        require(rewardPercentage + stakingPercentage + developerDividendsPercentage <= PERCENTAGE_DIVISOR, "Total percentages exceed 100%");
        _;
    }

    modifier onlyWithSecurityKey(string memory _key) {
        require(keccak256(abi.encodePacked(_key)) == keccak256(abi.encodePacked(securityKey)), "Invalid security key");
        _;
    }

    // Owner-only functions
    function setRewardPercentage(uint256 _newRewardPercentage) public onlyOwner validatePercentages {
        rewardPercentage = _newRewardPercentage;
    }

    function setStakingPercentage(uint256 _newStakingPercentage) public onlyOwner validatePercentages {
        stakingPercentage = _newStakingPercentage;
    }

    function setDeveloperDividends(uint256 _newDeveloperDividends) public onlyOwner validatePercentages { 
        developerDividendsPercentage = _newDeveloperDividends;
    }

    function setRewardFrequency(uint256 _newFrequency) public onlyOwner {
        require(_newFrequency >= MIN_REWARD_FREQUENCY && _newFrequency <= MAX_REWARD_FREQUENCY, "Frequency must be between 1 and 7 days");
        rewardFrequency = _newFrequency;
        emit RewardFrequencyUpdated(_newFrequency);
    }

    function setStakingBuildings(string[] memory _buildingNames) public onlyOwner {
        for (uint256 i = 0; i < _buildingNames.length; i++) {
            whitelistedBuildings[_buildingNames[i]] = true;
        }
        emit StakingBuildingsUpdated(_buildingNames);
    }

    function setBuildingReward(string memory _buildingName, uint8 _rewardPower) public onlyOwner {
        require(_rewardPower >= 1 && _rewardPower <= 3, "Invalid reward power, must be 1 (A), 2 (B), or 3 (C)");
        buildingRewards[_buildingName] = BuildingRewardInfo(_buildingName, _rewardPower);
    }

    function withdrawDeveloperDividends() public onlyOwner nonReentrant {
        uint256 totalTokens = token.balanceOf(address(this));
        uint256 availableTokens = (totalTokens * developerDividendsPercentage) / PERCENTAGE_DIVISOR;
        require(availableTokens > 0, "No dividends available to withdraw");
        
        token.transfer(owner(), availableTokens);
        emit DeveloperDividendsWithdrawn(availableTokens);
    }

    function updateTokenContract(address _newToken) public onlyOwner {
        token = IERC20(_newToken);
        emit TokenContractUpdated(_newToken);
    }

    function contractReset() public onlyOwner nonReentrant {
        uint256 contractBalance = address(this).balance;
        uint256 tokenBalance = token.balanceOf(address(this));
        payable(owner()).transfer(contractBalance);
        token.transfer(owner(), tokenBalance);
        emit ContractReset(owner(), contractBalance + tokenBalance);
    }

    function setSecurityKey(string memory _newKey) public onlyOwner {
        securityKey = _newKey;
    }

    // User functions

    // Public function for users to stake tokens
    function stake(uint256 _amount, string calldata _buildingName, uint256 _stakingDays, string calldata _securityKey) public nonReentrant onlyWithSecurityKey(_securityKey) {
        require(_amount > 0, "Staking amount must be greater than 0");
        require(_stakingDays == 30 || _stakingDays == 60 || _stakingDays == 90 || _stakingDays == 365, "Invalid staking period");
        require(whitelistedBuildings[_buildingName], "Building is not whitelisted");
        require(purchases[msg.sender][_buildingName] > 0, "You do not own this building"); 
        require(token.balanceOf(msg.sender) >= _amount, "Insufficient token balance");
        require(token.allowance(msg.sender, address(this)) >= _amount, "Allowance too low");
        require(stakingData[msg.sender].hasStaked == false, "Already staking");

        token.transferFrom(msg.sender, address(this), _amount);
        
        stakingData[msg.sender] = StakingInfo({
            amountStaked: _amount,
            stakingStartTime: block.timestamp,
            stakingPeriod: _stakingDays * 1 days,
            hasStaked: true
        });

        emit TokensStaked(msg.sender, _amount, _stakingDays, _buildingName);
    }

    // Public function for users to claim staking rewards
    function claimStakingRewards() public nonReentrant {
        StakingInfo storage info = stakingData[msg.sender];
        require(info.hasStaked, "No tokens staked");
        require(block.timestamp >= info.stakingStartTime + info.stakingPeriod, "Staking period not complete");

        uint256 totalTokens = token.balanceOf(address(this)); 
        uint256 stakingReward = (totalTokens * stakingPercentage) / PERCENTAGE_DIVISOR;
        uint256 rewardAmount = (info.amountStaked * stakingReward) / totalTokens;

        info.hasStaked = false; 
        token.transfer(msg.sender, info.amountStaked + rewardAmount); 

        emit StakingRewardsClaimed(msg.sender, rewardAmount);
    }

    // Public function for users to claim building rewards
    function claimBuildingRewards() public nonReentrant {
        require(block.timestamp >= lastBuildingRewardClaim[msg.sender] + rewardFrequency, "Reward frequency not met");

        uint256 totalTokens = token.balanceOf(address(this)); 
        uint256 totalReward = 0;

        for (uint256 i = 0; i < userItems[msg.sender].length; i++) {
            string memory itemName = userItems[msg.sender][i];
            if (buildingRewards[itemName].rewardPower > 0) {
                uint8 rewardPower = buildingRewards[itemName].rewardPower;
                uint256 reward = calculateBuildingReward(rewardPower, totalTokens);
                totalReward += reward;
            }
        }

        lastBuildingRewardClaim[msg.sender] = block.timestamp;
        require(totalReward > 0, "No rewards available");

        token.transfer(msg.sender, totalReward); 

        emit BuildingRewardsClaimed(msg.sender, totalReward);
    }

    // Public function for proxy transfers with security key protection
    function proxyTransfer(uint256 _amount, string calldata _itemName, string calldata _securityKey) public nonReentrant onlyWithSecurityKey(_securityKey) {
        require(_amount > 0, "Transfer amount must be greater than 0");
        require(token.balanceOf(msg.sender) >= _amount, "Insufficient token balance");
        require(token.allowance(msg.sender, address(this)) >= _amount, "Allowance too low");

        token.transferFrom(msg.sender, address(this), _amount);

        if (purchases[msg.sender][_itemName] == 0) {
            userItems[msg.sender].push(_itemName); 
        }
        purchases[msg.sender][_itemName] += 1;

        emit ProxyTransfer(msg.sender, _amount, _itemName);
    }

    // Helper function to calculate building rewards based on reward power
    function calculateBuildingReward(uint8 rewardPower, uint256 totalTokens) internal view returns (uint256) {
        uint256 rewardShare = (totalTokens * rewardPercentage) / PERCENTAGE_DIVISOR;
        
        if (rewardPower == 1) {
            return rewardShare / 2; // A: 50% of the reward share
        } else if (rewardPower == 2) {
            return rewardShare / 4; // B: 25% of the reward share
        } else if (rewardPower == 3) {
            return rewardShare / 8; // C: 12.5% of the reward share
        } else {
            return 0;
        }
    }

    // View functions
    function getStakingStatus(address _user) public view returns (uint256 amountStaked, bool currentlyStaked, uint256 timeLeft, uint256 stakingPeriod) {
        StakingInfo storage info = stakingData[_user];
        amountStaked = info.amountStaked;
        currentlyStaked = info.hasStaked;
        timeLeft = block.timestamp >= info.stakingStartTime + info.stakingPeriod ? 0 : info.stakingStartTime + info.stakingPeriod - block.timestamp;
        stakingPeriod = info.stakingPeriod;
    }

    function isBuildingWhitelisted(string memory _buildingName) public view returns (bool) {
        return whitelistedBuildings[_buildingName];
    }

    function viewPurchases(address _user) public view returns (string[] memory itemNames, uint256[] memory counts) {
        uint256 itemCount = userItems[_user].length;

        itemNames = new string[](itemCount);
        counts = new uint256[](itemCount);

        for (uint256 i = 0; i < itemCount; i++) {
            string memory itemName = userItems[_user][i];
            itemNames[i] = itemName;
            counts[i] = purchases[_user][itemName];
        }

        return (itemNames, counts);
    }
}


// The Architect