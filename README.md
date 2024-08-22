# City-P2E-Staking-Rewards-Smart-Contract
This repository contains a smart contract for a Play-to-Earn (P2E) system built on Ethereum. The contract allows users to stake ERC-20 tokens in whitelisted buildings, earn staking rewards, and claim building-specific rewards based on their ownership and the reward power of their buildings. The contract is designed with security in mind, featuring an owner-controlled configuration, security key protection for specific operations, and support for periodic reward claims. Ideal for blockchain-based games that integrate staking and reward mechanisms.

Key Features:

Staking: Users can stake tokens for predefined periods (30, 60, 90, 365 days) and earn rewards.
Building Rewards: Users can claim daily rewards based on the buildings they own and their reward power.
Security Key: Ensures that certain operations, like staking and proxy transfers, are protected and can only be initiated within the game.
Owner Control: Configuration settings such as reward percentages, staking buildings, and security keys are managed by the contract owner.
ERC-20 Token Compatible: Fully compatible with ERC-20 tokens.


Usage:

Stake Tokens: Users can stake tokens in whitelisted buildings and claim rewards after the staking period ends.
Claim Rewards: Daily building rewards can be claimed based on the user's inventory and the set reward frequency.
Contract Management: The owner can update settings, manage developer dividends, and reset the contract if needed.

This smart contract was designed by 3D Studio for 3D City: Metaverse

Searching for a team of highly skilled developers? Reach out to us at office@3dcity.life


Contents of P2E.sol

Core Functions and Their Operations
1. Owner-Required Functions
These functions can only be executed by the contract owner and are essential for configuring the contract, managing rewards, and ensuring the contract operates as intended.

setRewardPercentage(uint256 _newRewardPercentage)

Description: This function allows the contract owner to set the percentage of the total tokens in the contract that will be allocated for building rewards.
Parameters:
_newRewardPercentage: A uint256 value representing the percentage of the total tokens to allocate for building rewards.
Example Usage:
solidity
Copy code
setRewardPercentage(15);
This sets 15% of the total tokens in the contract as the building rewards pool.
setStakingPercentage(uint256 _newStakingPercentage)

Description: This function sets the percentage of the total tokens in the contract allocated for staking rewards.
Parameters:
_newStakingPercentage: A uint256 value representing the percentage of the total tokens to allocate for staking rewards.
Example Usage:
solidity
Copy code
setStakingPercentage(20);
This sets 20% of the total tokens in the contract as the staking rewards pool.
setDeveloperDividends(uint256 _newDeveloperDividends)

Description: This function allows the contract owner to define the percentage of the total tokens that are allocated as dividends to the developer.
Parameters:
_newDeveloperDividends: A uint256 value representing the percentage of the total tokens allocated as developer dividends.
Example Usage:
solidity
Copy code
setDeveloperDividends(5);
This sets 5% of the total tokens in the contract as the developer’s dividends.
setRewardFrequency(uint256 _newFrequency)

Description: This function defines the time interval at which building rewards can be claimed by users. The interval is set in seconds, allowing the owner to control how often rewards can be withdrawn.
Parameters:
_newFrequency: A uint256 value representing the frequency in seconds at which users can claim their building rewards.
Example Usage:
solidity
Copy code
setRewardFrequency(86400);
This sets the reward frequency to 24 hours (86400 seconds).
setStakingBuildings(string[] memory _buildingNames)

Description: This function allows the owner to whitelist specific buildings that users can stake tokens on, ensuring that only approved buildings are eligible for staking.
Parameters:
_buildingNames: An array of strings representing the names of the buildings to be whitelisted.
Example Usage:
solidity
Copy code
setStakingBuildings(["BuildingA", "BuildingB"]);
This whitelists "BuildingA" and "BuildingB" for staking.
setBuildingReward(string memory _buildingName, uint8 _rewardPower)

Description: This function whitelists buildings for building rewards and assigns them a reward power, which determines their share of the reward pool. The reward power is categorized into three levels: A (1), B (2), and C (3).
Parameters:
_buildingName: A string representing the name of the building.
_rewardPower: A uint8 value representing the building’s reward power (1 for A, 2 for B, 3 for C).
Example Usage:
solidity
Copy code
setBuildingReward("BuildingA", 1);
This sets "BuildingA" with a reward power of A (highest).
withdrawDeveloperDividends()

Description: This function allows the contract owner to withdraw the developer’s share of tokens from the contract, based on the percentage set by setDeveloperDividends.
Parameters: None.
Example Usage:
solidity
Copy code
withdrawDeveloperDividends();
This withdraws the developer’s dividends from the contract.
updateTokenContract(address _newToken)

Description: This function allows the owner to update the ERC-20 token contract address that the smart contract interacts with. It is essential for managing which token the contract operates on.
Parameters:
_newToken: The address of the new ERC-20 token contract.
Example Usage:
solidity
Copy code
updateTokenContract("0x1234..."); // Replace with the actual token contract address
This updates the token contract to the new address provided.
contractReset()

Description: This function allows the owner to withdraw all tokens and native currency (ETH) from the contract, effectively resetting the contract’s state. This is useful in situations where the contract needs to be cleared or reinitialized.
Parameters: None.
Example Usage:
solidity
Copy code
contractReset();
This withdraws all assets from the contract to the owner’s address.
setSecurityKey(string memory _newKey)

Description: This function allows the owner to set or update the security key required for certain secure operations, such as staking and proxy transfers.
Parameters:
_newKey: A string representing the new security key.
Example Usage:
solidity
Copy code
setSecurityKey("newSecurityKey123");
This updates the security key to "newSecurityKey123".
2. Non-Owner Functions
These functions are accessible to all users who interact with the smart contract. They allow players to stake tokens, claim rewards, and make secure in-game purchases.

stake(uint256 _amount, string calldata _buildingName, uint256 _stakingDays, string calldata _securityKey)

Description: This function allows users to stake their tokens into the contract for a specified period. The function requires a security key to prevent unauthorized staking outside of the game. The tokens are locked for the chosen duration, and the user is rewarded at the end of the staking period.
Parameters:
_amount: The amount of tokens to stake.
_buildingName: The name of the building on which the tokens are staked.
_stakingDays: The duration of the staking period (30, 60, 90, or 365 days).
_securityKey: The security key to authorize the staking transaction.
Example Usage:
solidity
Copy code
stake(100, "BuildingA", 90, "securityKey123");
This stakes 100 tokens on "BuildingA" for 90 days, using the security key "securityKey123".
claimStakingRewards()

Description: This function allows users to claim their staked tokens and any earned rewards once the staking period has ended. It checks that the staking period is complete and calculates the rewards based on the staked amount and staking duration.
Parameters: None.
Example Usage:
solidity
Copy code
claimStakingRewards();
This claims the staked tokens and rewards after the staking period ends.
claimBuildingRewards()

Description: This function allows users to claim rewards based on the buildings they own in their inventory. The rewards are calculated according to the reward power of each building and are subject to the defined reward frequency.
Parameters: None.
Example Usage:
solidity
Copy code
claimBuildingRewards();
This claims building rewards based on the user’s eligible buildings.
proxyTransfer(uint256 _amount, string calldata _itemName, string calldata _securityKey)

Description: This function allows users to transfer tokens to the contract securely, often for the purpose of in-game purchases. It requires a security key to ensure the transaction is authorized.
Parameters:
_amount: The amount of tokens to transfer.
_itemName: The name of the item being purchased.
_securityKey: The security key to authorize the transfer.
Example Usage:
solidity
Copy code
proxyTransfer(50, "ItemA", "securityKey123");
This transfers 50 tokens to purchase "ItemA", using the security key "securityKey123".
3. View Functions
These functions allow users to view specific information about the contract and their interactions with it. They are read-only and do not modify the state of the contract.

getStakingStatus(address _user)

Description: This view function returns the staking status of a user, including the amount staked, whether they are currently staked, the time left until the staking period ends, and the staking period duration.
Parameters:
_user: The address of the user whose staking status is being queried.
Example Usage:
solidity
Copy code
getStakingStatus("0x1234...");
This returns the staking status for the user with address "0x1234...".
isBuildingWhitelisted(string memory _buildingName)

Description: This view function checks if a particular building is whitelisted for staking. It is useful for users to verify if a building is eligible before attempting to stake tokens on it.
Parameters:
_buildingName: The name of the building being checked.
Example Usage:
solidity
Copy code
isBuildingWhitelisted("BuildingA");
This checks if "BuildingA" is whitelisted for staking.
viewPurchases(address _user)

Description: This view function returns a list of items that a user has purchased or owns in their inventory. It provides users with an overview of their in-game assets.
Parameters:
_user: The address of the user whose purchases are being queried.
Example Usage:
solidity
Copy code
viewPurchases("0x1234...");
This returns the list of items owned by the user with address "0x1234...".
Security Mechanisms
The smart contract incorporates several security features to ensure that all operations are conducted safely and without risk of unauthorized access or manipulation:

Reentrancy Guard: The contract uses the ReentrancyGuard from OpenZeppelin to prevent reentrancy attacks. This mechanism ensures that functions cannot be re-entered during execution, which could otherwise lead to vulnerabilities where tokens are withdrawn multiple times.

Security Key System: Critical functions, such as stake and proxyTransfer, require a security key to execute. This key ensures that these operations are only performed by authorized entities, typically from within the game environment. This system prevents unauthorized access and ensures that the contract is used as intended.

Owner-Only Controls: Functions that affect the configuration of the contract, such as setting reward percentages, updating token contracts, and resetting the contract, are restricted to the owner. This limitation ensures that only trusted parties can make significant changes to the contract.

Immutable Records: All staking, purchasing, and reward transactions are recorded on the blockchain, providing an immutable record that cannot be altered. This transparency is crucial for maintaining trust within the community, as players can independently verify that the contract operates fairly.

Operational Flow and Usage
The smart contract is designed to be user-friendly while maintaining a high level of functionality and security. Below is an operational flow and usage guide for the most common interactions:

1. Staking Tokens
Action: Players stake their tokens for a specified duration.
Process: The player calls the stake function, specifying the amount, building, duration, and security key.
Outcome: Tokens are locked in the contract, and the player is set to receive rewards at the end of the staking period.
2. Claiming Staking Rewards
Action: After the staking period ends, players claim their tokens and rewards.
Process: The player calls the claimStakingRewards function, which checks eligibility and transfers the tokens.
Outcome: The player receives their original staked tokens plus any earned rewards.
3. Claiming Building Rewards
Action: Players claim rewards based on the buildings they own.
Process: The player calls the claimBuildingRewards function, which calculates rewards based on building power levels.
Outcome: The player receives rewards proportional to their building holdings.
4. Making In-Game Purchases
Action: Players purchase items using tokens.
Process: The player calls the proxyTransfer function, specifying the item and security key.
Outcome: The specified amount of tokens is transferred, and the item is added to the player’s inventory.
5. Viewing Status
Action: Players check their staking status or inventory.
Process: The player calls the getStakingStatus or viewPurchases function.
Outcome: The player receives detailed information about their current staking or inventory status.
