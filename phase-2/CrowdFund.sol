//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    address public creator;
    uint256 public goal;
    // The minimum goal for the campaign to be considered successful

    uint256 public fundsRaised;
    uint256 public deadline; //Deadline for the crowdfunding campaign
    bool public ended;
    bool public success;

    modifier onlyCreator{
        require(msg.sender == creator, "Only the creator can call this function");
        _;
    }

    mapping(address => uint256) public contributions;
    address[] public contributors;

    event Funded(address indexed _from, uint256 _value);
    event Success();
    event Failure();

    constructor(uint _goal, uint _deadline) public {
        creator = msg.sender;
        goal = _goal;
        deadline = block.timestamp +(_deadline * 1 days);
        fundsRaised = 0;
        ended = false;
        success = false;
    }

    // Function to contribute funds to the campaign
    function contribute() public payable {
        require(!ended, "Campaign has already ended");
        require(block.timestamp < deadline, "Campaign deadline has passed");
        require(msg.value > 0, "Cannot contribute 0 or negative value");
        require((fundsRaised + msg.value) <= goal, "Goal exceeded");

        fundsRaised += msg.value;
        contributions[msg.sender] += msg.value;
        contributors.push(msg.sender);
        emit Funded(msg.sender, msg.value);

        // Check if the campaign has reached its goal
        if (address(this).balance == goal) {
            success = true;
            ended = true;
            emit Success();
        }
    }

    // Function to refund all contributors if the campaign is unsuccessful
    function refund() internal{
        require(!success, "Campaign was successful, no refunds are needed");

        for (uint256 i = 0; i < contributors.length; i++) {
            address contributor = contributors[i];
            uint256 contribution = contributions[contributor];
            require(payable(contributor).send(contribution), "Failed to send refund");
        }
   }

    // Function to end the campaign early if it is unsuccessful
    function cancel() public {
        require(!ended, "Campaign has already ended");

        refund();
        ended = true;
        emit Failure();
    }

    // Function to withdraw the remaining funds (if any) after the campaign ends
    function withdraw() public onlyCreator{
        require(ended, "Campaign has not yet ended");
        uint256 remaining = address(this).balance;
        require(remaining > 0, "No funds to withdraw");
        require(payable(creator).send(remaining), "Failed to send funds");
    }
    // Function to get the total number of contributors
    function getContributionCount() public view returns (uint256) {
        return contributors.length;
    }

    fallback() external payable {}
}
