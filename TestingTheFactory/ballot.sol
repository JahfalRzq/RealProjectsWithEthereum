// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


contract CampaignFactory {
    address[] public deployedCampaigns;

    // Fungsi untuk membuat campaign baru
    function createCampaign(uint minimum) public {
        Campaign newCampaign = new Campaign(minimum, msg.sender);
        deployedCampaigns.push(address(newCampaign));
    }

    // Menambahkan 'memory' pada return array
    function getDeployedCampaigns() public view returns (address[] memory) {
        return deployedCampaigns;
    }
}

contract Campaign {
    struct Request {
        string description;
        uint value;
        address recipient;
        bool complete;
        uint approvalCount;
        mapping(address => bool) approvals;
    }

    Request[] public requests;
    address public manager;
    uint public minimumContribution;
    mapping(address => bool) public approvers;
    uint public approversCount;

    modifier restricted() {
        require(msg.sender == manager, "Only the manager can call this function.");
        _;
    }

    // Gunakan 'constructor' untuk mendefinisikan fungsi konstruksi
    constructor(uint minimum, address creator) {
        manager = creator;
        minimumContribution = minimum;
    }

    function contribute() public payable {
        require(msg.value > minimumContribution, "Contribution must be greater than the minimum.");

        approvers[msg.sender] = true;
        approversCount++;
    }

    // Tambahkan 'memory' pada parameter string
    function createRequest(string memory description, uint value, address recipient) public restricted {
    // Membuat instance baru dalam storage
    Request storage newRequest = requests.push();

    // Mengisi setiap field struct secara manual
    newRequest.description = description;
    newRequest.value = value;
    newRequest.recipient = recipient;
    newRequest.complete = false;
    newRequest.approvalCount = 0;
}

    function approveRequest(uint index) public {
        Request storage request = requests[index];

        require(approvers[msg.sender], "You must be an approver to approve.");
        require(!request.approvals[msg.sender], "You have already approved this request.");

        request.approvals[msg.sender] = true;
        request.approvalCount++;
    }

    function finalizeRequest(uint index) public restricted {
        Request storage request = requests[index];

        require(request.approvalCount > (approversCount / 2), "Not enough approvals.");
        require(!request.complete, "Request has already been finalized.");

        // Gunakan 'payable' untuk alamat penerima
        payable(request.recipient).transfer(request.value);
        request.complete = true;
    }
}