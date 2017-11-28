pragma solidity ^0.4.18;
contract MultisigWallet{

	//variables
	address[] public owner; //May not need an owner at the very moment
	uint constant public max_owner = 3; //Will Change once I can get 3 party members to work.
	uint public required_amount; //How many parties needed for MultiSigWallet
	uint public transactionCount;

	//Events - publicize actions to external listeners
	event Deposit(address indexed sender, uint value);
	event AddOwner(address indexed owner);
	event RemoveOwner(address indexed owner);
	event Agreement(address indexed sender, uint transactionID);
	event Rejection(address indexed sender, uint transactionID);
	event Submission(uint indexed transactionID);
	event ExecutionFailure(uint transactionID);
	event Execution(uint transactionID);
	event Requirement(uint required_amount);
	//Struct
	struct Transaction {
		address destination;
		uint value;
	}
	//Mappings
	mapping (address => uint) public transactions; //A list of all the transaction that has occured
	mapping (address => bool) public isOwner; //A list of who are the parties involved

	//Modifiers
	modifier ownerDoesNotExist(address owner) {
			if (isOwner[owner]);
				_;
	}
	modifier ownerExists(address owner) {
			if (!isOwner[owner]);
				_;
	}
	// Constructor, can receive one or many variables here; only one allowed
	function MultisigWallet(address[] _owners, uint _required_amount)
	{
		owners = _owners;
		required_amount = _required_amount
	}
	// Fallback function for failure in transactions.
	function addOwner(address owner) public
			ownerDoesNotExist(owner)
	{
			isOwner[owner] = true;
			owners.push(owner);
			 AddOwner(owner);
	}

	function removeOwner(address owner) public
			ownerExists(owner)
	{
			isOwner[owner] = False;
			owners.push(owner);
			 removeOwner(owner);
	}

	function changeRequirement(uint _required_amount) public
	{
			_required_amount = _required_amount;
			RequirementChange(_required_amount);
	}
	function getOwners() public constant returns (address[])
	{
			return owners;
	}
	// Must redo because I am having trouble using it.
	function addTransaction(address destination, uint value) public returns (uint transactionID){
		{
				transactionId = transactionCount;
				transactions[transactionId] = Transaction({
						destination: destination,
						value: value,
				});
				transactionCount += 1;
				Submission(transactionId);
		}
	}

	function submitTransaction(address destination, uint value) public returns (uint transactionId)
	{
			transactionId = addTransaction(destination, value);
			confirmTransaction(transactionId);
	}

	function confirmTransaction(uint transactionId) public
			ownerExists(msg.sender)
			transactionExists(transactionId)
	{
			confirmations[transactionId][msg.sender] = true;
			Confirmation(msg.sender, transactionId);
			executeTransaction(transactionId);
	}

	function revokeConfirmation(uint transactionId) public
			ownerExists(msg.sender)
			transactionExists(transactionId)
	{
			confirmations[transactionId][msg.sender] = false;
			Rejection(msg.sender, transactionId);
	}
	function executeTransaction(uint transactionId) public
			ownerExists(msg.sender)
	{
			if (isConfirmed(transactionId)) {
					Transaction tx = transactions[transactionId];
					tx.executed = true;
					if (tx.destination.call.value(tx.value)(tx.data))
							Execution(transactionId);
					else {
							ExecutionFailure(transactionId);
							tx.executed = false;
					}
			}
	}
	function isConfirmed(uint transactionId) public constant returns (bool)
	{
			uint count = 0;
			for (uint i=0; i<owners.length; i++) {
					if (confirmations[transactionId][owners[i]])
							count += 1;
					if (count == required)
							return true;
			}
	}
	function () {
			revert();
	}
}
