# Web3 Design-Bid-Build (DBB) System Simple Celo-Tutorial

In this beginer tutorial what we are going to be building is a revolutionary approach to the traditional construction project delivery method known as Design-Bid-Build (DBB). By leveraging the power of blockchain technology, specifically Web3, this system aims to bring unprecedented levels of transparency, security, and efficiency to the construction industry.

In the traditional DBB method, a project goes through three main phases: design, bid, and build. In the design phase, architects and engineers create detailed plans for the project. In the bid phase, contractors submit their bids for the project. Finally, in the build phase, the winning contractor builds the project according to the design plans.

Our Web3 DBB system takes this process to the next level by integrating it with blockchain technology. From transparent bidding on decentralized platforms to NFT-backed design ownership, decentralized escrow for bid deposits, decentralized project documentation, smart contract-enforced payment milestones, decentralized quality assurance and inspections, and blockchain-based supply chain tracking, every aspect of the DBB process is enhanced.

The current alternatives to this system are traditional DBB methods and other project delivery methods like Design-Build (DB) and Construction Manager at Risk (CMAR). While these methods have their own advantages, they lack the transparency, security, and efficiency that a blockchain-based system can provide. With the Web3 DBB system, every transaction is transparent and immutable, every design is tokenized for clear ownership rights, and every process is automated for maximum efficiency.

## Table of Contents
1. Prerequisites
2. Requirements
3. Building our Smart Contract
4. Testing the Smart Contract
5. Potential improvements
6. Conclusion

## Prerequisites
- For this tutorial we will use <https://remix.ethereum.org/> , an online IDE for web 3 and we won't have to worry about installing the prerequisites.
- Solidity: This is the programming language used for writing smart contracts on platforms like Ethereum and Celo.
- Truffle or Hardhat: These are development frameworks for Ethereum that allow you to compile, deploy, test, and debug your smart contracts.
- MetaMask or Celo Extension Wallet: These are browser extensions that allow you to interact with the Ethereum or Celo blockchain, respectively.
- Infura or DataHub: These are blockchain infrastructure platforms that provide APIs to connect your application to the Ethereum or Celo network.
- Web3.js or ethers.js: These are JavaScript libraries for interacting with the Ethereum blockchain.

## Requirements
- Good internet connection
- A basic understanding of Solidity and smart contracts
- A basic understanding of blockchain and Web3

## Building our Smart Contract
### Create a Solidity File

Navigate to [Remix IDE](https://remix.ethereum.org/).

Create a new File

Name it whatever you like but makesure it is a solidity file in my case  ``` designsell.sol```

Add the following code


```solidity
pragma solidity >=0.8.0 <0.9.0;

contract DBBServices {

    // Owner of the contract
    address private owner;

    // Emergency stop switch
    bool private stopped = false;
}

```

```pragma solidity >=0.8.0 <0.9.0;```: This line specifies that the code is written in Solidity language and it is compatible with any compiler version between 0.8.0 and 0.9.0 (0.9.0 excluded).
```contract DBBServices { ... }```: This defines a new contract named ```DBBServices```. A contract in Solidity is a collection of code (its functions) and data (its state) that resides at a specific address on the Ethereum blockchain.
```address private owner;```: This line declares a private variable ```owner``` of type ```address```. In Ethereum, an ```address``` type variable is used to store Ethereum addresses.
```bool private stopped = false;```: This line declares a private boolean variable ```stopped``` and initializes it to ```false```. This variable can be used as a switch for emergency stops in the contract’s functions.


### Create Data Structures
```solidity
    // struct for Project to be built
    struct Project {
        string name; // The name of the project
        string description; // A brief description of the project
        bool isActive; // A boolean value indicating whether the project is active
        uint256 price; // The bid price for the project
        address owner; // The address of the project owner
        bool[] isBooked; // An array of boolean values indicating whether the project is booked
    }
```
This part of the code defines a ```struct``` called ```Project```. A ```struct``` is a custom data type that allows you to combine different types of data (like strings, booleans, addresses, etc.). Each ```Project``` has a ```name```, ```description```, ```isActive``` status, ```price```, ```owner```, and ```isBooked``` status.

```solidity
    uint256 public projectId;
```
This line declares a public variable ```projectId``` of type ```uint256``` (an unsigned integer of 256 bits). The ```public``` keyword means that this variable can be read from outside the contract.

```solidity
    // mapping of projectId to Project object
    mapping(uint256 => Project) public projects;
```

This line declares a public ```mapping``` called ```projects```. A ```mapping``` is like an associative array or a hash that associates ```projectId``` (a ```uint256```) with a ```Project``` object. The ```public``` keyword means that this mapping can be read from outside the contract.

```solidity
    // struct for Bid
    struct Bid {
        uint256 projectId;
        uint256 bidDate;
        uint256 bidAmount;
        address bidder;
    }
```
This part of the code defines a ```struct``` called ```Bid```. A ```struct``` is a custom data type that allows you to combine different types of data. Each ```Bid``` has a ```projectId```, ```bidDate```, ```bidAmount```, and ```bidder```.

```solidity
    uint256 public bidId;
```
This line declares a public variable ```bidId``` of type ```uint256``` (an unsigned integer of 256 bits). The ```public``` keyword means that this variable can be read from outside the contract.

```solidity
    // mapping of bidId to Bid object
    mapping(uint256 => Bid) public bids;
```
This line declares a public ```mapping``` called ```bids```. A ```mapping``` is like an associative array or a hash that associates ```bidId``` (a ```uint256```) with a Bid object. The ```public``` keyword means that this mapping can be read from outside the contract.

### Define Events

```solidity
    // This event is emitted when a new project is created
    event NewProject (
    uint256 indexed projectId
    );

    // This event is emitted when a new bid is placed
    event NewBid (
    uint256 indexed projectId,
    uint256 indexed bidId
    );

    // This event is emitted when a bid is accepted
    event BidAccepted (
    uint256 indexed projectId,
    uint256 indexed bidId
    );

    // This event is emitted when a project milestone is reached
    event MilestoneReached (
    uint256 indexed projectId,
    uint256 milestoneIndex
    );

    // This event is emitted when a project is completed
    event ProjectCompleted (
    uint256 indexed projectId
    );
```
- ```NewProject```: This event is emitted when a new project is created. It includes the ```projectId``` as an indexed parameter, which means it can be used as a filter in the event logs.
- ```NewBid```: This event is emitted when a new bid is placed. It includes both the ```projectId``` and ```bidId``` as indexed parameters, allowing you to filter the event logs based on either or both of these values.
- ```BidAccepted```: This event is emitted when a bid is accepted. Like ```NewBid```, it includes both the ```projectId``` and ```bidId``` as indexed parameters.
- ```MilestoneReached```: This event is emitted when a project milestone is reached. It includes the ```projectId``` and the ```milestoneIndex``` (the index of the milestone that was reached) as indexed parameters.
- ```ProjectCompleted```: This event is emitted when a project is completed. It includes the ```projectId``` as an indexed parameter.

### Smart Contract Functions
#### Modifier functions
```solidity
    // Modifier for functions that can only be used by the owner
    modifier isOwner {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }


    // Modifier for emergency stop
    modifier stopInEmergency { if (!stopped) _; }
    modifier onlyInEmergency { if (stopped) _; }
```
Modifiers are a way to change the behavior of functions in a declarative way. They are placed before the function name and can be used to modify the function’s behavior.
- ```isOwner```: This modifier ensures that only the owner of the contract can call certain functions. It does this by checking if ```msg.sender``` (the address calling the function) is equal to ```owner``` (the owner of the contract). If not, it throws an error with the message “Only the contract owner can call this function”.
- ```stopInEmergency``` and ```onlyInEmergency```: These two modifiers are used for an “emergency stop” mechanism. The ```stopInEmergency``` modifier allows a function to be called only when the contract is not stopped. The ```onlyInEmergency``` modifier allows a function to be called only when the contract is stopped.

```solidity
    constructor() {
        owner = msg.sender;  // Set the contract owner to the address that deployed the contract
    }
```
The ```constructor``` is a special function that is executed during the creation of the contract. In this case, it sets the ```owner``` of the contract to ```msg.sender```, which is the address that deployed the contract.

```solidity
    // Emergency stop function
    function toggleContractActive() isOwner public {
        stopped = !stopped;
    }
```
The ```toggleContractActive``` function allows the owner to stop or start the contract. This is often used in case there’s a bug or some other issue with the contract. It uses the ```isOwner``` modifier, so only the owner can call it.

#### createNewProject Function
```solidity
    // This function is used to create a new project
    
    function createProject(string memory name, string memory description, uint256 price) public stopInEmergency {
    projects[projectId] = Project(name, description, true, price, msg.sender, new bool[](365));
    emit NewProject(projectId++);
    }
```
This function, ```createProject```, is used to create a new project in the contract. Here’s a breakdown of what it does:

- Function Parameters: The function takes three parameters - ```name```, ```description```, and ```price```. These are the details of the project that is being created.
- Modifier: The function has a ```stopInEmergency``` modifier. This means that the function can only be called when the contract is not stopped (i.e., in an emergency).
- Creating the Project: Inside the function, a new Project struct is created with the provided ```name```, ```description```, and ```price```. The ```isActive``` field is set to ```true```, the ```owner``` is set to ```msg.sender``` (the address calling the function), and ```isBooked``` is a new boolean array of length 365 (which could represent the days of a year).
- Storing the Project: The new ```Project``` is then stored in the ```projects``` mapping at the position of the current ```projectId```.
- Emitting an Event: After the project is created, the ```NewProject``` event is emitted with the ```projectId``` as an argument. This allows external entities to listen for this event and react whenever a new project is created.
- Incrementing the projectId: Finally, the ```projectId``` is incremented with ```projectId++```. This ensures that each new project will have a unique ID.

#### placeBid Function

```solidity
    // This function is used to place a new bid on a project
    function placeBid(uint256 _projectId, uint256 bidAmount) public payable stopInEmergency {
    require(projects[_projectId].isActive, "Project with this ID is not active");
    require(msg.value == bidAmount, "Sent insufficient funds");

    bids[bidId] = Bid(_projectId, block.timestamp, bidAmount, msg.sender);
    emit NewBid(_projectId, bidId++);
    }
```

This function, ```placeBid```, is used to place a new bid on a project. Here’s a breakdown of what it does:

- Function Parameters: The function takes two parameters - ```_projectId``` and ```bidAmount```. These represent the ID of the project that the bid is for and the amount of the bid, respectively.
- Modifier: The function has a ```stopInEmergency``` modifier. This means that the function can only be called when the contract is not stopped (i.e., in an emergency).
- Requirements: Inside the function, there are two ```require``` statements. These are used to check that certain conditions are met before the function continues. If these conditions are not met, the function will throw an error and stop executing.
> The first ```require``` statement checks that the project with the given ```_projectId``` is active. If not, it throws an error with the message “Project with this ID is not active”.
> The second ```require``` statement checks that the value sent with the transaction (```msg.value```) is equal to the  ```bidAmount```. If not, it throws an error with the message “Sent insufficient funds”.
- Placing the Bid: If both conditions are met, a new ```Bid``` struct is created with the ```_projectId```, the current block timestamp (```block.timestamp```), the ```bidAmount```, and the address of the bidder (```msg.sender```). This ```Bid``` is then stored in the ```bids``` mapping at the position of the current ```bidId```.
- Emitting an Event: After the bid is placed, the ```NewBid``` event is emitted with the ```_projectId``` and ```bidId``` as arguments. This allows external entities to listen for this event and react whenever a new bid is placed.
- Incrementing the bidId: Finally, the ```bidId``` is incremented with ```bidId++```. This ensures that each new bid will have a unique ID.

#### acceptBid Function

```solidity
    // This function is used to accept a bid on a project
    function acceptBid(uint256 _bidId) public stopInEmergency {
    Bid storage bid = bids[_bidId];
    Project storage project = projects[bid.projectId];

    require(msg.sender == project.owner, "Only the project owner can accept bids");
    require(project.isActive, "Project with this ID is not active");

    project.isActive = false;
    project.owner = bid.bidder;

    emit BidAccepted(bid.projectId, _bidId);
    }
```
This function, ```acceptBid```, is used to accept a bid on a project. Here’s a breakdown of what it does:

- Function Parameters: The function takes one parameter - ```_bidId```. This represents the ID of the bid that is being accepted.
-  Modifier: The function has a ```stopInEmergency``` modifier. This means that the function can only be called when the contract is not stopped (i.e., in an emergency).
- Loading the Bid and Project: Inside the function, the ```Bid``` and ```Project``` associated with the ```_bidId``` are loaded into memory for easy access. This is done with the ```bids[_bidId]``` and ```projects[bid.projectId]``` expressions, respectively.
- Requirements: There are two ```require``` statements. These are used to check that certain conditions are met before the function continues. If these conditions are not met, the function will throw an error and stop executing.
> The first ```require``` statement checks that the function caller (```msg.sender```) is the owner of the project. If not, it throws an error with the message “Only the project owner can accept bids”.
> The second ```require``` statement checks that the project is active. If not, it throws an error with the message “Project with this ID is not active”.
- Accepting the Bid: If both conditions are met, the project is marked as inactive (```project.isActive = false```) and the owner of the project is set to the bidder (```project.owner = bid.bidder```). This represents the transfer of ownership from the original owner to the winning bidder.
- Emitting an Event: After the bid is accepted, the ```BidAccepted``` event is emitted with the ```projectId``` and ```_bidId``` as arguments. This allows external entities to listen for this event and react whenever a bid is accepted.

#### projectMilestoneReached Function

```solidity
    // This function is used to mark a project milestone as reached
    function markMilestone(uint256 _projectId, uint256 milestoneIndex) public stopInEmergency {
    Project storage project = projects[_projectId];

    require(msg.sender == project.owner, "Only the project owner can mark milestones");
    require(milestoneIndex < project.isBooked.length, "Invalid milestone index");

    project.isBooked[milestoneIndex] = true;

    emit MilestoneReached(_projectId, milestoneIndex);
    }
```
This function, ```markMilestone```, is used to mark a milestone of a project as reached. Here’s a breakdown of what it does:

- Function Parameters: The function takes two parameters - ```_projectId``` and ```milestoneIndex```. These represent the ID of the project and the index of the milestone that is being marked as reached, respectively.
- Modifier: The function has a ```stopInEmergency``` modifier. This means that the function can only be called when the contract is not stopped (i.e., in an emergency).
- Loading the Project: Inside the function, the ```Project``` associated with the ```_projectId``` is loaded into memory for easy access. This is done with the ```projects[_projectId]``` expression.
- Requirements: There are two ```require``` statements. These are used to check that certain conditions are met before the function continues. If these conditions are not met, the function will throw an error and stop executing.
> The first ```require``` statement checks that the function caller (```msg.sender```) is the owner of the project. If not, it throws an error with the message “Only the project owner can mark milestones”.
> The second ```require``` statement checks that the ```milestoneIndex``` is less than the length of the ```isBooked``` array. If not, it throws an error with the message “Invalid milestone index”.
- Marking the Milestone: If both conditions are met, the milestone at the given ```milestoneIndex``` is marked as reached by setting ```project.isBooked[milestoneIndex]``` to ```true```.
- Emitting an Event: After the milestone is marked, the ```MilestoneReached``` event is emitted with the ```_projectId``` and ```milestoneIndex``` as arguments. This allows external entities to listen for this event and react whenever a milestone is reached.

#### markProjectAsComplete Function

```solidity
    // This function is used to mark a project as completed
    function completeProject(uint256 _projectId) public stopInEmergency {
    Project storage project = projects[_projectId];

    require(msg.sender == project.owner, "Only the project owner can complete the project");

    emit ProjectCompleted(_projectId);
    }
```
This function, ```completeProject```, is used to mark a project as completed. Here’s a breakdown of what it does:

- Function Parameters: The function takes one parameter - ```_projectId```. This represents the ID of the project that is being marked as completed.
- Modifier: The function has a ```stopInEmergency``` modifier. This means that the function can only be called when the contract is not stopped (i.e., in an emergency).
- Loading the Project: Inside the function, the ```Project``` associated with the ```_projectId``` is loaded into memory for easy access. This is done with the ```projects[_projectId]``` expression.
- Requirement: There is a ```require``` statement. This is used to check that a certain condition is met before the function continues. If this condition is not met, the function will throw an error and stop executing.
> The ```require``` statement checks that the function caller (```msg.sender```) is the owner of the project. If not, it throws an error with the message “Only the project owner can complete the project”.
- Emitting an Event: After the project is marked as completed, the ```ProjectCompleted``` event is emitted with the ```_projectId``` as an argument. This allows external entities to listen for this event and react whenever a project is completed.

#### withdrawFunds Function
```solidity
    // Function to withdraw funds
    function withdraw() public isOwner {
        payable(owner).transfer(address(this).balance);
    }
```
This function, ```withdraw```, is used to withdraw funds from the contract. Here’s a breakdown of what it does:

Modifier: The function has an ```isOwner``` modifier. This means that the function can only be called by the owner of the contract.
Withdrawal: Inside the function, all the funds from the contract (represented by ```address(this).balance```) are transferred to the owner of the contract. This is done with the ```transfer``` function, which sends ether from the contract to another address.

## Testing the Smart Contract
we need to [compile and deploy](https://docs.celo.org/developer/deploy/remix) it. when you are done compiling and deploying your smart contract you can expect to see your smart contract which will look like this.

![remix ide image](https://github.com/trader18512/SimpleDBB_Celo-Tutorial/blob/main/Screenshot_17-3-2024_19547_remix.ethereum.org.jpeg)


##Possible Improvements

As this is a simple project to get your feet wet there is potential for much more improvements the following are but a few;
1. Security Concerns:
- Re-entrancy Attacks: The withdraw function could be susceptible to re-entrancy attacks. This could be mitigated by following the checks-effects-interactions pattern in Solidity.
- Gas Limit: Functions that interact with large data structures (like the isBooked array in the Project struct) could potentially exceed the block gas limit, causing transactions to fail.
- Underflow/Overflow: The incrementing of projectId and bidId could potentially lead to overflow errors. Using a library like OpenZeppelin’s SafeMath could help prevent this.
2. Implementation Concerns:
- Scalability: Storing all project and bid data on-chain can be expensive and may not scale well. You might want to consider storing only essential data on-chain and the rest off-chain.
- Data Validation: There is no validation of the input data in the createProject and placeBid functions. Adding checks to validate the input could improve the robustness of the contract.
3. Possible Additional Features:
- Dispute Resolution: There is currently no mechanism for resolving disputes between project owners and bidders. Implementing such a mechanism could be beneficial.
- Multiple Bidders: The contract could be extended to allow multiple bidders to bid on a project and for the project owner to choose the best one.
- Milestone Payments: Instead of transferring the entire bid amount at once, payments could be made as each milestone is reached.
## Conclusion
In this tutorial, we’ve explored a Solidity smart contract designed for managing construction projects on the blockchain. We’ve learned about various components of the contract, including structs for representing projects and bids, mappings for storing these objects, events for logging significant occurrences, and functions for creating projects, placing bids, accepting bids, marking milestones, completing projects, and withdrawing funds.

We’ve also discussed some potential concerns and areas for improvement for the project, including security issues, implementation details, possible additional features, and usability concerns. Hope the tutorial was helpful.

You can access the [full code](https://github.com/trader18512/SimpleDBB_Celo-Tutorial/blob/main/DBBservices.sol) here, 
