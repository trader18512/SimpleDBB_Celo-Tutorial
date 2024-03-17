// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

contract DBBServices {

    // Owner of the contract
    address public owner;

    // Emergency stop switch
    bool private stopped = false;

    // struct for Project to be built
    struct Project {
        string name;
        string description;
        bool isActive; // is project active
        uint256 price; // bid price 
        address owner; // project owner
        bool[] isBooked;
    }

    uint256 public projectId;

    // mapping of projectId to Project object
    mapping(uint256 => Project) public projects;

    // struct for Bid
    struct Bid {
        uint256 projectId;
        uint256 bidDate;
        uint256 bidAmount;
        address bidder;
    }

    uint256 public bidId;

    // mapping of bidId to Bid object
    mapping(uint256 => Bid) public bids;

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

    // Modifier for functions that can only be used by the owner
    modifier isOwner {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    // Modifier for emergency stop
    modifier stopInEmergency { if (!stopped) _; }
    modifier onlyInEmergency { if (stopped) _; }

    constructor() {
        owner = msg.sender;  // Set the contract owner to the address that deployed the contract
    }

    // Emergency stop function
    function toggleContractActive() isOwner public {
        stopped = !stopped;
    }

    
    // This function is used to create a new project
    
    function createProject(string memory name, string memory description, uint256 price) public stopInEmergency {
    projects[projectId] = Project(name, description, true, price, msg.sender, new bool[](365));
    emit NewProject(projectId++);
    }

    // This function is used to place a new bid on a project
    function placeBid(uint256 _projectId, uint256 bidAmount) public payable stopInEmergency {
    require(projects[_projectId].isActive, "Project with this ID is not active");
    require(msg.value == bidAmount, "Sent insufficient funds");

    bids[bidId] = Bid(_projectId, block.timestamp, bidAmount, msg.sender);
    emit NewBid(_projectId, bidId++);
    }

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

    // This function is used to mark a project milestone as reached
    function markMilestone(uint256 _projectId, uint256 milestoneIndex) public stopInEmergency {
    Project storage project = projects[_projectId];

    require(msg.sender == project.owner, "Only the project owner can mark milestones");
    require(milestoneIndex < project.isBooked.length, "Invalid milestone index");

    project.isBooked[milestoneIndex] = true;

    emit MilestoneReached(_projectId, milestoneIndex);
    }

    // This function is used to mark a project as completed
    function completeProject(uint256 _projectId) public stopInEmergency {
    Project storage project = projects[_projectId];

    require(msg.sender == project.owner, "Only the project owner can complete the project");

    emit ProjectCompleted(_projectId);
    }

    // Function to withdraw funds
    function withdraw() public isOwner {
        payable(owner).transfer(address(this).balance);
    }
}
