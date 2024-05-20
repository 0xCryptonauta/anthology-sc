// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

struct Memoir {
    uint8 id;
    address admin;
    string title;
    string description;
    bool state;

    uint timestamp;
    //enum memoirType{Text, Youtube, Twitter, Link}
}

contract AnthologyContract {

    function uint256ToUint8(uint256 value) public pure returns (uint8) {
        require(value <= 255, "Value is too large to fit in uint8");
        return uint8(value);
    }
    // ----------------------------------------------------------------------------------------------------------
    // ---------------------------------------- BASE DEFINITION -------------------------------------------------
    // ----------------------------------------------------------------------------------------------------------

    address public superUser;
    address public proposedSuperUser;
    string public contractName;
    uint8 public maxMemoirs;                  // How different would be if uint16 (performance readings)
    uint16 public maxWhiteListed;

    uint8 nextMemoirId;
    uint8 public createdMemoirsCount;       // Lifetime times that memoirs have been created
    
    //Active Memoirs
    mapping (uint8 => Memoir) public memoirs;
    uint8[] public activeMemoirs;      //maxMemoirs - availableMemoirs
    uint8[] public availableMemoirs;   //maxMemoirs - activeMemoirs

    //Whitelist addresses
    mapping(address => bool) public whitelist;
    address[] public whitelistedAddresses; //uint16 max -> 65535

    // ----------------------------------------------------------------------------------------------------------
    // ---------------------------------------------- EVENTS ----------------------------------------------------
    // ----------------------------------------------------------------------------------------------------------

    event SuperUserPropostion (address newSuperUser);
    event SuperUserDeleted(address previousSuperUser);
    event SuperUserDenied(address almostSuperUser);
    event SuperUserTransferred(address previousSuperUser, address newSuperUser);

    event MemoirDeleted(uint8 indexed deletedId);
    event MemoirAdded(uint8 indexed memoirId, Memoir newMemoir);

    // ----------------------------------------------------------------------------------------------------------
    // -------------------------------------------- CONSTRUCTOR -------------------------------------------------
    // ----------------------------------------------------------------------------------------------------------

    constructor( ) {
        // Initialize state variables in the constructor
        superUser = msg.sender;
        contractName = "";
        maxMemoirs = 10;
        nextMemoirId = 0;
        createdMemoirsCount = 0;
        maxWhiteListed = 255;
        proposedSuperUser = address(0);

        for (uint8 i = 255; i > 0; i--) {
            availableMemoirs.push(i);
        }
        availableMemoirs.push(0);
    }

    // ----------------------------------------------------------------------------------------------------------
    // --------------------------------------------- SUPER USER -------------------------------------------------
    // ----------------------------------------------------------------------------------------------------------

    modifier onlySuperUser {
        require(msg.sender == superUser, "Unauthorized: You are not the owner of the contract.");
        _;
    }

    function updateMaxMemoirs(uint8 newMax) onlySuperUser public {
        require(newMax >= activeMemoirs.length, "New max must be greater than the active memoirs count");
        maxMemoirs = newMax;
    }

    // ----------------------------------------------------------------------------------------------------------
    // ----------------------------------------------- DANGER ---------------------------------------------------
    // ----------------------------------------------------------------------------------------------------------

    function assignName ( string memory _newName) onlySuperUser public {
        require(bytes(_newName).length < 32);
        contractName = _newName;
    }

    function deleteSuperUser () onlySuperUser public {
        emit SuperUserDeleted(superUser);
        superUser = address(0);
    }

    function proposeSuperUser(address newOwner) onlySuperUser public {
        require(newOwner != address(0), "Invalid address (0x.....)");
        emit SuperUserPropostion(newOwner);
        proposedSuperUser = newOwner;
    }

    function acceptSuperUser() public {
        require(msg.sender == proposedSuperUser, "Unauthorized: You are not the proposed new admin");
        emit SuperUserTransferred(superUser, proposedSuperUser);
        superUser = proposedSuperUser;
        proposedSuperUser = address(0);
    }

    function denySuperUser() public {
        require(msg.sender == proposedSuperUser, "Unauthorized: You are not the proposed new admin");
        emit SuperUserDenied(msg.sender);
        proposedSuperUser = address(0);
    }

    // ----------------------------------------------------------------------------------------------------------
    // -------------------------------------------- WHITELIST ---------------------------------------------------
    // ----------------------------------------------------------------------------------------------------------

     modifier onlyWhitelisted {
        require(whitelistedAddresses.length == 0 || whitelist[msg.sender] || msg.sender == superUser, "You have no power over this contract.");
        _;
    }

     // Add an address to the whitelist
    function addToWhitelist(address user) public onlySuperUser() {
        require(whitelist[user] == false, "User already whitelisted");
        whitelist[user] = true;
        whitelistedAddresses.push(user);
    }

    //TO-DO: add require
    function addManyToWhitelist(address[] memory users) public onlySuperUser() {
        for (uint8 i=0; i<users.length; i++){
            require(whitelist[users[i]] == false, "User already whitelisted");
            whitelist[users[i]] = true;
            whitelistedAddresses.push(users[i]);
        }
    }

    function cleanWhitelist() public onlySuperUser{  
        require(whitelistedAddresses.length > 0, "There is no whitelisted accounts");
        for (uint8 i=0; i<whitelistedAddresses.length; i++){
            whitelist[whitelistedAddresses[i]] = false;
        }
        whitelistedAddresses = new address[](0);
    }

    function resetAllMemoirs () public onlySuperUser {
        
        for (uint8 i=0; i<activeMemoirs.length; i++){
            delete memoirs[activeMemoirs[i]];
        }

        delete activeMemoirs;
        delete availableMemoirs;

        for (uint8 i = 255; i > 0; i--) {
            availableMemoirs.push(i);
        }
        availableMemoirs.push(0);
    }

    // Remove an address from the whitelist
    function removeFromWhitelist(address user) public onlySuperUser() {
        whitelist[user] = false;

        // Remove the address from the whitelistedAddresses array
        for (uint16 i = 0; i < whitelistedAddresses.length; i++) {
            if (whitelistedAddresses[i] == user) {
                // Swap with the last element and then pop
                whitelistedAddresses[i] = whitelistedAddresses[whitelistedAddresses.length - 1];
                whitelistedAddresses.pop();
                break;
            }
        }
    }

    // Check if an address is whitelisted
    function isWhitelisted(address user) public view returns (bool) {
        return whitelist[user];
    }

    // Get the total number of whitelisted addresses
    function getWhitelistedCount() public view returns (uint8) {      // HOW TO LOWER SIZE (length fault)
        return uint256ToUint8(whitelistedAddresses.length);
    }

    // Get the list of whitelisted addresses
    function getWhitelistedAddresses() public view returns (address[] memory) {     // can this be set to max size maxWhitelisted?
        return whitelistedAddresses;
    }

    // ----------------------------------------------------------------------------------------------------------
    // --------------------------------------------- VIEWABLE ---------------------------------------------------
    // ----------------------------------------------------------------------------------------------------------

    function getContractInfo () public view returns (uint8, uint8, uint8, uint8[] memory, address, string memory, address) {
        return (createdMemoirsCount, maxMemoirs, uint256ToUint8(activeMemoirs.length), activeMemoirs ,superUser, contractName, proposedSuperUser);
    }

    // Get memoir given by id
    function getMemoir (uint8 _id) public view returns ( Memoir memory) {
        return memoirs[_id] ;
    }

    // Get all memoirs
    function getAllMemoirs () public view returns (Memoir[] memory) {
        Memoir[] memory sws = new Memoir[](uint256ToUint8(activeMemoirs.length));
        
        for (uint8 i = 0; i<uint256ToUint8(activeMemoirs.length); i++){
            sws[i] = memoirs[activeMemoirs[i]];
        }
        return sws;
    }
    
    // ----------------------------------------------------------------------------------------------------------
    // ---------------------------------------- MAIN FUNCTIONS --------------------------------------------------
    // ----------------------------------------------------------------------------------------------------------

    // with sender as admin
    function createMemoir ( string memory _title, string memory _description) onlyWhitelisted public {
        require(activeMemoirs.length < maxMemoirs, "Maximum number of memoirs reached. Cannot create more memoirs.");
        require(bytes(_title).length <= 16);
        require(bytes(_description).length <= 150);
        nextMemoirId = availableMemoirs[uint256ToUint8(availableMemoirs.length-1)];
        memoirs[nextMemoirId] = Memoir(nextMemoirId, msg.sender, _title, _description, false, block.timestamp);
        activeMemoirs.push(nextMemoirId);
        availableMemoirs.pop();
        createdMemoirsCount++; 
        emit MemoirAdded(nextMemoirId, memoirs[nextMemoirId]);

    }

    // with admin as parameter
    function createMemoir ( address _admin, string memory _title, string memory _description) onlyWhitelisted public {
        require(activeMemoirs.length < maxMemoirs, "Maximum number of memoirs reached. Cannot create more memoirs.");
        require(bytes(_title).length <= 16);
        require(bytes(_description).length <= 150);
        nextMemoirId = availableMemoirs[uint256ToUint8(availableMemoirs.length)-1];
        memoirs[nextMemoirId] = Memoir(nextMemoirId, _admin, _title, _description, false, block.timestamp);
        activeMemoirs.push(nextMemoirId);
        availableMemoirs.pop();
        createdMemoirsCount++; 
        emit MemoirAdded(nextMemoirId, memoirs[nextMemoirId]);
    }

    function toggleMemoir (uint8 _id) public {
        require (msg.sender == memoirs[_id].admin || msg.sender == superUser, "Sender is not admin of this memoir");
        memoirs[_id].state = !memoirs[_id].state;
    }

    // Deprecate -> better to delete and create new
    function updateMemoir (uint8 _id, string memory _title, string memory _description) public { 
        if (msg.sender == memoirs[_id].admin || msg.sender == superUser) {
        memoirs[_id].title = _title;
        memoirs[_id].description = _description;
        }
        else {
            revert ("Sender is not admin of this memoir");
        }
    }

    function deleteMemoir (uint8 _id) onlySuperUser public {
        uint8 index = findIndex(_id);
        require(index < 255, "ID Memoir not found");    //255 == not found
        delete memoirs[_id];

        availableMemoirs.push(_id);
        activeMemoirs[index] = activeMemoirs[uint256ToUint8(activeMemoirs.length) - 1];
        activeMemoirs.pop();
        emit MemoirDeleted(_id);
    }


    function findIndex(uint8 valueToFind) public view returns (uint8) {
        for (uint8 i = 0; i < activeMemoirs.length; i++) {
            if (activeMemoirs[i] == valueToFind) {
                return uint8(i);
            }
        }
        return uint8(255);
    }
}
