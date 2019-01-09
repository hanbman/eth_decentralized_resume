pragma solidity ^0.5.0;

import "./Ownable.sol";

contract Resume is Ownable {

  // ////////////////////////////////////////////////////////////// //
  // /////////////////////// DECLARATIONS ////////////////////////// //
  // ////////////////////////////////////////////////////////////// //

  /* set owner */
  address private _owner;

  /* keep track of the users, institutions, and entries */
  uint private UserCount;
  uint private InstitutionCount;
  uint private EntryCount;

  /* keep a list of Admins that can add universities, users, entries */
  
  mapping(address => bool) private admins;

  /* uint public transcript_price;

  // ///////////////////////     USERS    ////////////////////////// //

  /* keep a list of valid users */
  
  mapping(address => bool) userList;
  
  /* Creating a public mapping that maps the user address to the user ID. */
    
  mapping (address => uint) userIDMaps;
  
  /* Creating a public mapping that maps the UserID (a number) to a User. */
    
  mapping (uint => User) public users;

  /* Creating a struct named User. 
  Can expand more details about the User in the future- 
  address, age, etc
  */
  
  struct User {
        string name;
        uint date_joined;
        address userAddr;
    }

  // ////////////////////////////////////////////////////////////// //


  // /////////////////////// INSTITUTIONS ////////////////////////// //

  /* keep a list of valid institutions */
  
  mapping(address => bool) institutionList;
  
  /* Creating a public mapping that maps the institution address to the institution ID. */
    
  mapping (address => uint) institutionIDMaps;
  
  /* Creating a public mapping that maps the InstitutionID (a number) to an Instituion. */
    
  mapping (uint => Institution) public institutions;

  /* Creating an enum called institutionType for types of institutions */
  
  enum institutionType {University, School, Certificator}

  /* Creating a struct named Institution. 
  Can expand more details about the Institution in the future- 
  address, year of inception, etc
  */
  
  struct Institution {
        string name;
        uint date_joined;
        institutionType itype;
        address institutionAddr;
    }

  // ////////////////////////////////////////////////////////////// //
  

  // /////////////////////// RESUMES ////////////////////////// //

  /* Creating a public mapping that maps the UserID (a number) to a resume.
  Each user is mapped to one resume, and joined using UserID
  There is also a resume_queue for each user of entries that have yet to
  be approved by the user. 
   */
    
  mapping (uint => uint[]) public resumes;
  mapping (uint => uint[]) public resume_queues;
  
  /* This maps user id to entry id in a user queue so we can check if an entry
  exists in a user queue*/
  mapping (uint ==> uint) private queueMaps;

  /* Each resume and resume queue is an array of unique entryids that string 
  together resumes filled with entries
   */

  uint[] public the_resume;
  uint[] public resume_queue;

  // ////////////////////////////////////////////////////////////// //

  
  // /////////////////////// ENTRIES ////////////////////////// //
  
  /* Creating a mapping that maps the EntryID (a number) to an entry.
  Each resume is an array of entries
   */
  
  mapping (uint => Entry) entries;
  
  /* Creating a struct named Entry. 
  These are individual entries in the resume- there are two types of entries accounting for
  1. receiving a degree from a University or School
  2. receiving a certification from a Certificator
  */
  
  enum entryType {Degree, Certificate}
  
  /* struct of the entry containing info about the individual entry
  - recipient- the user who is receiving the entry
  - approved- boolean True/False for if the review is approved by receiver to prevent
  malicious reviews to be added to someone's transcript. Default to False until user goes to 
  approve it and it will be added to their resume. 
  - entry_title- title of the degree or certificate earned eg. B.S. bachelor of science
  - degree_descr- description of the entry such as the major for a degree, or specialization of a certificate
  - institutionID- the id of the institution issuing the entry
  - date_received- date that the entry was issued
  - start_date- when the degree or certificate is valid
  - end_date- when the degree or certificate is not valid
  - review- gives a review of the user- can be a recommendation, etc

  */
  struct Entry {
        address recipient;
        bool approved;
        string entry_title;
        string degree_descr;
        uint institutionID;
        uint date_received;
        uint start_date;
        uint end_date;
        entryType etype;
        string review;
    }

  // ////////////////////////////////////////////////////////////// //
  

  // ////////////////////////////////////////////////////////////// //
  // /////////////////////// END OF DECLARATIONS ////////////////////////// //
  // ////////////////////////////////////////////////////////////// //
  
  
  
  // ////////////////////////////////////////////////////////////// //
  // /////////////////////// EVENTS ////////////////////////// //
  // ////////////////////////////////////////////////////////////// //

  /* Create events*/

    event AddedAdmin(address adminAddr);
    event SetPrice(uint price);
    event AddedInstitution(uint UniversityID);
    event AddedUser(uint UserID);
    event EntryCreated(uint EntryID);
    event AddedtoQueue(uint EntryID, uint UserID);
    event AddedtoResume(uint EntryID, uint UserID);
    event EntryRejected(uint EntryID, uint UserID);

  // ////////////////////////////////////////////////////////////// //
  // /////////////////////// END OF EVENTS ////////////////////////// //
  // ////////////////////////////////////////////////////////////// //


  // ////////////////////////////////////////////////////////////// //
  // /////////////////////// MODIFIERS ////////////////////////// //
  // ////////////////////////////////////////////////////////////// //

    // Do not forget the "_;"! It will
    // be replaced by the actual function
    // body when the modifier is used.
  
  /* This check to see if caller is the owner. Inherited from ownable contract*/
  modifier onlyOwner() {
        require(isOwner(), "This action is prohibited for non Owner.");
        _;
    }

  /* a set of modifiers to check if an address is a valid admin, user, or institution*/
  modifier verifyAdmin () 
    { 
      require (admins[msg.sender]==true, "This action is prohibited for non Admins.");
      _;
    }
  
  modifier verifyUser () 
    { 
      require (userList[msg.sender]==true, "Not a valid User.");
      _;
    }

  modifier verifyInstitution () 
    { 
      require (institutionList[msg.sender]==true, "Not a valid Institution.");
      _;
    }
  
  /* A modifer that checks if the msg.sender is the the right address */
  modifier verifyCaller (address _address) 
    { 
      require (msg.sender == _address, "Message sender is not correct.");
      _;
    }

  
  /* A modifer that checks if the address given is a valid user */
  modifier verifyUserEntry (address _address) 
    { 
      require (userList[_address]==true, "Cannot add entry to this user.");
      _;
    }

  /* A modifer that checks if queue for a user is empty */
  modifier verifyQueueEmpty (address _address) 
    { 
      uint private queue_length= resume_queues[userIDMaps[_address]].length;
      require (queue_length>0, "There are no entries in your queue.");
      _;
    }

  /* A modifer that checks if the user is trying to approve their own entry */
  modifier verifyUserApproval (uint _UserID)
    { 
      require (_UserID==userIDMaps[msg.sender], "This entry is not assigned to you.");
      _;
    }

  /* A modifer that checks if entry is first entry in queue */
  modifier verifyNextEntryUp (uint _EntryID)
    { 
      require (_EntryID==resume_queues[userIDMaps[msg.sender]][0], 
      "This entry is not the next one in your queue.");
      _;
    }

  // ////////////////////////////////////////////////////////////// //
  // /////////////////////// END OF MODIFIERS ////////////////////////// //
  // ////////////////////////////////////////////////////////////// //


  // ////////////////////////////////////////////////////////////// //
  // /////////////////////// FUNCTIONS ////////////////////////// //
  // ////////////////////////////////////////////////////////////// //

  /* This is the constructor
  We are setting the owner to the one who starts this contract
  Sets the owner as the first admin
  UserCount, InstitutionCount, and EntryCount set to 1 since we start IDs at 1 */
  constructor() payable public {
    /* Set the owner as the person who instantiated the contract
    Set the counts of Users, Institions, and Entries to 0. */
    _owner=msg.sender;
    admins[_owner]=true;
    UserCount=1;
    InstitutionCount=1;
    EntryCount=1;
    transcript_price=0;
  }

  /* This function lets the owner of the contract add admins to manage the contract */
  function addAdmin(address admin)
  public
  onlyOwner()
  returns(bool)
  {
    admins[admin]=true;
    emit AddedAdmin(admin);
    return true;
  }

  function setTranscriptPrice(uint _price)
  public
  onlyOwner()
  returns(bool)
  {
    transcript_price=_price;
    emit SetPrice(_price);
    return true;
  }
  
  /* This function let's users sign up for this service to record their resumes */
  function signUpUser(string memory _name)
  public
  returns(bool)
  {
    users[UserCount] = User({name: _name, date_joined: now, userAddr: msg.sender});
    userIDMaps[msg.sender]=UserCount;
    userList[msg.sender]=true;
    emit AddedUser(UserCount);
    UserCount = UserCount + 1;
    return true;
  }

  /* This function let's admins add institutions that are legitimate, allowing them submit
  entries for users on the platform*/
  function addInstitution(string memory _name, address _institutionAddr, institutionType _itype) 
  public
  verifyAdmin()
  returns(bool)
  {
    institutionIDMaps[_institutionAddr]=InstitutionCount;
    institutions[InstitutionCount] = Institution({name: _name, date_joined: now, itype: _itype, institutionAddr: _institutionAddr});
    institutionList[_institutionAddr]=true;
    emit AddedInstitution(InstitutionCount);
    InstitutionCount = InstitutionCount + 1;
    return true;
  }

  /* This function let's institutions add entries that can go on the resumes of users*/
  function addEntry(address _recipient, string memory _entry_title, string memory _degree_descr, 
  uint _start_date, uint _end_date, entryType _etype, string memory _review) 
  public
  verifyInstitution()
  verifyUserEntry(_recipient)
  returns(bool)
  {
    //Create the entry
    bool _approved=false;
    uint _institutionID=institutionIDMaps[msg.sender];
    uint _date_received=now;
    entries[EntryCount] = Entry({recipient: _recipient, approved: _approved,
    entry_title: _entry_title, degree_descr: _degree_descr, institutionID: _institutionID,
    date_received: _date_received, start_date: _start_date, end_date: _end_date, 
    etype: _etype, review: _review});
    emit EntryCreated(EntryCount);

    //Add entry to the user's resume queue and map to user
    uint _UserID=userIDMaps[_recipient];
    resume_queues[_UserID].push(EntryCount);
    queueMaps[EntryCount]=_UserID;
    emit AddedtoQueue(EntryCount, _UserID);

    //Advance EntryCount and end function by returning true
    EntryCount = EntryCount + 1;
    return true;
  }

  /* This function let's users approve entries in their resume queue
  Once the entry is approved, it moves from resume queue to the offical resume
  If it rejected, then we just remove it from the queue
  */
  function approveEntry(uint _entryID, bool _doYouWantToApprove)
  public
  verifyUserApproval(queueMaps[_entryID])
  verifyQueueEmpty(msg.sender)
  verifyNextEntryUp (_entryID)
  returns(bool)
  {
    _nextEntryID=resume_queues[userIDMaps[msg.sender]][0];
    uint _length=resume_queues[userIDMaps[msg.sender]].length
    /* The first element of the queue is removed
    and we shift all other elements up one and reduce size of array by 1
    for (uint i = 0; i < resume_queues[_length - 1; i++) 
    {
      resume_queues[userIDMaps[msg.sender]][i]=resume_queues[userIDMaps[msg.sender]][i+1];
    }
    delete resume_queues[userIDMaps[msg.sender]][_length-1];
    resume_queues[userIDMaps[msg.sender]].length--;
    if (_doYouWantToApprove==true)
    {
      resumes[userIDMaps[msg.sender]].push(_nextEntryID);
      emit AddedtoResume(_entryID, userIDMaps[msg.sender]);
    }
    else
    {
      emit EntryRejected(_entryID, userIDMaps[msg.sender]);
    }
    return true;
  }

  /* This function let's user view the first item in their queue
  No ability to return arrays yet in solidity???
  */
  function showMyResumeQueue()
    public 
    view
    verifyUser()
    verifyQueueEmpty(msg.sender)
    returns (uint entryID, string memory entry_title, string memory degree_descr,
    string memory institution_name, uint date_received, uint start_date, 
    uint end_date, string memory review) 
    {
    uint _latestID=resume_queues[userIDMaps[msg.sender]][0];
    entryID = _latestID;
    entry_title=entries[_latestID].entry_title;
    degree_descr=entries[_latestID].degree_descr;
    institution_name=institutions[entries[_latestID].institutionID].name;
    date_received=entries[_latestID].date_received;
    start_date=entries[_latestID].start_date;
    end_date=entries[_latestID].end_date;
    review=entries[_latestID].review;
    return (entryID, entry_title, degree_descr, institution_name, date_received,
    start_date, end_date, review);
    }

  /* This function let's the owner check who is an admin
  */
  function isAdmin(address _adminAddr)
    public
    view 
    onlyOwner()
    returns (bool) 
    {
    return (admins[_adminAddr])
    }        

/*

  /* Add a keyword so the function can be paid. This function should transfer money
    to the seller, set the buyer as the person who called this transaction, and set the state
    to Sold. Be careful, this function should use 3 modifiers to check if the item is for sale,
    if the buyer paid enough, and check the value after the function is called to make sure the buyer is
    refunded any excess ether sent. Remember to call the event associated with this function!*/

  function buyItem(uint _sku)
    public
    payable
    forSale (_sku)
    paidEnough (items[_sku].price)
    checkValue (_sku)
  {
    items[_sku].seller.transfer(items[_sku].price);
    items[_sku].buyer=msg.sender;
    items[_sku].state=State.Sold;
    emit Sold(_sku);
  }

  /* Add 2 modifiers to check if the item is sold already, and that the person calling this function
  is the seller. Change the state of the item to shipped. Remember to call the event associated with this function!*/
  function shipItem(uint _sku)
    public
    sold (_sku)
    verifyCaller(items[_sku].seller)
  {
    items[_sku].state=State.Shipped;
    emit Shipped(_sku);
  }

  /* Add 2 modifiers to check if the item is shipped already, and that the person calling this function
  is the buyer. Change the state of the item to received. Remember to call the event associated with this function!*/
  function receiveItem(uint _sku)
    public
    shipped (_sku)
    verifyCaller(items[_sku].buyer)
  {
    items[_sku].state=State.Received;
    emit Received(_sku);
  }

  /* We have these functions completed so we can run tests, just ignore it :) */
  function fetchItem(uint _sku) 
  public 
  view 
  returns (string memory name, uint sku, uint price, uint state, address seller, address buyer) 
  {
    name = items[_sku].name;
    sku = items[_sku].sku;
    price = items[_sku].price;
    state = uint(items[_sku].state);
    seller = items[_sku].seller;
    buyer = items[_sku].buyer;
    return (name, sku, price, state, seller, buyer);
  }

*/


  // ////////////////////////////////////////////////////////////// //
  // /////////////////////// END OF FUNCTIONS ////////////////////////// //
  // ////////////////////////////////////////////////////////////// //

}
