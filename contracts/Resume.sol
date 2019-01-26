pragma solidity ^0.5.0;

import "./Ownable.sol";
import "./BokkyPooBahsDateTimeLibrary.sol";
import "./SafeMath.sol";

contract Resume is Ownable {

    // The following libraries were found here https://github.com/ConsenSys/ethereum-developer-tools-list
    // Specify that this contract uses SafeMath library for operations involving uint
    using SafeMath for uint;
  
    // Specify that this contract uses BokkyPooBahsDateTimeLibrary for operations involving uint
    using BokkyPooBahsDateTimeLibrary for uint;
  
    // ////////////////////////////////////////////////////////////// //
    // /////////////////////// DECLARATIONS ////////////////////////// //
    // ////////////////////////////////////////////////////////////// //
    

    // no underscores between words
    // lower case starting and then upper case for first variables unless they are structs
    /// use triple slash for functions
    // no long comments

    //design choices
    //public and private variables
    //view functions
    //payable or not payable
    // why use only one entry returned for queue, and why do I need to shift the list so lists dont grow out of control
    // looping is just to keep the order of the array


    //loops- 
    // loops happen in javascript- individual transactions
    // batch sizes
    // good to do for future- link lists- send you link
    // pass in the queue element of current entry and delete the first entry


    
    /* set owner */
    address public _owner;
    
    // build in the Circuit Breaker / Pause Contract Functionality
    bool private emergency_stop;

    /* keep track of the users, institutions, and entries */
    uint private UserCount;
    uint private InstitutionCount;
    uint private EntryCount;

    /* keep a list of Admins that can add universities, users, entries */
    
    mapping(address => bool) private admins;

    // ///////////////////////     USERS    ////////////////////////// //

    /* when users sign up to be on the platform, they have to pay a set fee */
    
    uint public user_signup_fee;
    
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
    mapping (uint => uint) private queueMaps;

    /* Each resume and resume queue is an array of unique entryids that string 
    together resumes filled with entries
    */

    uint[] the_resume;
    uint[] resume_queue;

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
    event CircuitBreak(bool emergency_stopped);
    event SignUpFeeSet(uint fee);
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

     /* This checks if the contract is still active or if there has been an emergency stop*/
    modifier contractActive() {
        require(emergency_stop==false, "Contract is no longer active. Please contact owner.");
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

      /* A modifer that checks if the userID that you are trying to view exists */
    modifier verifyViewUserResume (uint _UserID) 
      { 
        require (userList[users[_UserID].userAddr]==true, "This ID is not a valid user.");
        _;
    }

    modifier paidEnough()
      { 
        require(msg.value >= user_signup_fee, "Not paid enough to sign up as a user."); 
        _;
    }
      
    modifier checkValue() 
      {
      //refund them after pay for item (why it is before, _ checks for logic before func)
        _;
        //uses the safemath library subtraction function
        uint amountToRefund = (msg.value).sub(user_signup_fee);
        if (amountToRefund>0)
            msg.sender.transfer(amountToRefund);
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
        uint queue_length= resume_queues[userIDMaps[_address]].length;
        require (queue_length>0, "There are no entries in your queue.");
        _;
    }

    /* A modifer that checks if the resume for a user is empty */
    modifier verifyResumeEmpty (uint _UserID) 
      { 
        uint _resumeLength = resumes[_UserID].length;
        require (_resumeLength>0, "There are no entries in this user's resume.");
        _;
    }

    /* A modifer that checks if the element of a resume to view is in bounds */
    modifier verifyResumeEntryExists (uint _UserID, uint _entryElement) 
      { 
        uint _resumeLength= resumes[_UserID].length;
        require (_entryElement<_resumeLength, "This entry element does not exist for this user.");
        _;
    }

    /* A modifer that checks if the resume entry to view has been approved by the user */
    modifier verifyApproved (uint _UserID, uint _entryElement)
      {
        
        require(entries[resumes[_UserID][_entryElement]].approved==true, "This entry has not been approved for viewing");
        _;
    }

    /* A modifer that checks if the user is trying to approve an entry that is assigned to them */
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
        _owner = msg.sender;
        emergency_stop = false;
        admins[_owner] = true;
        UserCount = 1;
        InstitutionCount = 1;
        EntryCount = 1;
        user_signup_fee = 0;
    }

    /* This function lets the owner of the contract add admins to manage the contract */
    function addAdmin(address admin)
    public
    contractActive()
    onlyOwner()
    returns(bool)
    {
        admins[admin] = true;
        emit AddedAdmin(admin);
        return true;
    }

     /* This function lets the owner of the contract change the contract state from 
     active to non-active and vice versa */
    function circuitBreakContract(bool _emergency_stop)
    public
    onlyOwner()
    returns(bool)
    {
        emergency_stop = _emergency_stop;
        emit CircuitBreak(_emergency_stop);
        return true;
    }
    
    /* This function lets the owner of the contract set the sign up fee for new users */
    function setSignUpFee(uint _fee)
    public
    contractActive()
    onlyOwner()
    returns(bool)
    {
        user_signup_fee = _fee;
        emit SignUpFeeSet(_fee);
        return true;
    }
    
    /* This function let's users sign up for this service to record their resumes */
    function signUpUser(string memory _name)
    public
    payable
    contractActive()
    paidEnough ()
    checkValue ()
    returns(bool)
    {
        users[UserCount] = User({name: _name, date_joined: now, userAddr: msg.sender});
        userIDMaps[msg.sender] = UserCount;
        userList[msg.sender] = true;
        emit AddedUser(UserCount);
        UserCount = UserCount + 1;
        return true;
    }

    /* This function let's admins add institutions that are legitimate, allowing them submit
    entries for users on the platform*/
    function addInstitution(string memory _name, address _institutionAddr, institutionType _itype) 
    public
    contractActive()
    verifyAdmin()
    returns(bool)
    {
        institutionIDMaps[_institutionAddr] = InstitutionCount;
        institutions[InstitutionCount] = Institution({name: _name, date_joined: now, itype: _itype, institutionAddr: _institutionAddr});
        institutionList[_institutionAddr] = true;
        emit AddedInstitution(InstitutionCount);
        InstitutionCount = InstitutionCount + 1;
        return true;
    }

    /* This function let's institutions add entries that can go on the resumes of users*/
    function addEntry(address _recipient, string memory _entry_title, string memory _degree_descr, 
        uint _start_date, uint _end_date, entryType _etype, string memory _review) 
    public
    contractActive()
    verifyInstitution()
    verifyUserEntry(_recipient)
    returns(bool)
    {
      //Create the entry
        bool _approved = false;
        uint _institutionID = institutionIDMaps[msg.sender];
        uint _date_received = now;
        entries[EntryCount] = Entry({recipient: _recipient, approved: _approved,
            entry_title: _entry_title, degree_descr: _degree_descr, institutionID: _institutionID,
            date_received: _date_received, start_date: _start_date, end_date: _end_date,
            etype: _etype, review: _review});
        emit EntryCreated(EntryCount);

      //Add entry to the user's resume queue and map to user
        uint _UserID = userIDMaps[_recipient];
        resume_queues[_UserID].push(EntryCount);
        queueMaps[EntryCount] = _UserID;
        emit AddedtoQueue(EntryCount, _UserID);

        //Advance EntryCount and end function by returning true
        EntryCount = EntryCount + 1;
        return true;
    }

    /* This function let's users approve entries in their resume queue
    Once the entry is approved, it moves from resume queue to the offical resume
    If it rejected, then we just remove it from the queue.
    This requires user to enter in the that the entry they are trying to edit
    is the next entry up in their queue so they are aware which one they are approving
    or rejecting.
    */
    function approveEntry(uint _entryID, bool _doYouWantToApprove)
    public
    contractActive()
    verifyUserApproval(queueMaps[_entryID])
    verifyQueueEmpty(msg.sender)
    verifyNextEntryUp (_entryID)
    returns(bool)
    {
        uint _nextEntryID = resume_queues[userIDMaps[msg.sender]][0];
        uint _length = resume_queues[userIDMaps[msg.sender]].length;
        /* The first element of the queue is removed
        and we shift all other elements up one and reduce size of array by 1*/
        for (uint i = 0; i < (_length - 1); i++) 
        {
            resume_queues[userIDMaps[msg.sender]][i] = resume_queues[userIDMaps[msg.sender]][i+1];
        }
        delete resume_queues[userIDMaps[msg.sender]][_length-1];
        resume_queues[userIDMaps[msg.sender]].length--;
        /* Now we add the entry to the resume if it is approved */
        if (_doYouWantToApprove==true)
        {
            entries[_nextEntryID].approved = true;
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
    After viewing, the user should call the approveEntry function to approve or disapprove 
    and then this will remove the entry either adding it to their official resume or removing it 
    from the queue. This is the only way to view the next entry in their queue
    No ability to return arrays yet in solidity???
    */
    function showMyResumeQueue()
      public 
      view
      contractActive()
      verifyUser()
      verifyQueueEmpty(msg.sender)
      returns (uint entryID, string memory entry_title, string memory degree_descr,
      string memory institution_name, uint date_received, uint start_date, 
      uint end_date, string memory review) 
      {
        uint _latestID = resume_queues[userIDMaps[msg.sender]][0];
        entryID = _latestID;
        entry_title = entries[_latestID].entry_title;
        degree_descr = entries[_latestID].degree_descr;
        institution_name = institutions[entries[_latestID].institutionID].name;
        date_received = entries[_latestID].date_received;
        start_date = entries[_latestID].start_date;
        end_date = entries[_latestID].end_date;
        review = entries[_latestID].review;
        return (entryID, entry_title, degree_descr, institution_name, date_received,
        start_date, end_date, review);
      }

    /* This function let's an external party view a user's offical resume
    This allows:
    1. A user to view their own resume
    2. A third party such as a company performing a background check to validate a resume
    It takes in the userID of the person you want to view, and the number of element of the resume
    to return.
    Since there is no good way to return an array of undefined size, and on top of that
    no good way to return an array of structs, we will allow the function caller to choose
    which element to view of a user's resume, starting with element 0. Element 0 will be the
    oldest entry added to a resume, while element resume.length-1 will be the newest entry. 
    It is useful to run the checkResumeSize function first to see how big the resume is 
    to choose which element to view.
    */
    function viewResume(uint _UserID, uint _entryElement)
      public 
      view
      contractActive()
      verifyViewUserResume (_UserID)
      verifyResumeEmpty (_UserID)
      verifyResumeEntryExists (_UserID, _entryElement)
      // verifyApproved(_UserID, _entryElement)
      returns (uint entryID 
      ,string memory entry_title 
      ,string memory degree_descr
      ,string memory institution_name 
      ,uint date_received 
      // ,uint start_date 
      // ,uint end_date 
      // ,string memory review
      )
    {
        entryID = resumes[_UserID][_entryElement];
        entry_title = entries[entryID].entry_title;
        degree_descr = entries[entryID].degree_descr;
        institution_name = institutions[entries[entryID].institutionID].name;
        date_received = entries[entryID].date_received;
      // start_date=entries[entryID].start_date;
      // end_date=entries[entryID].end_date;
      // review=entries[entryID].review;
        return (
        entryID
        , entry_title
        , degree_descr
        , institution_name
        , date_received
        // , start_date
        // , end_date
        // , review
        );
    }

    /* This function let's a user check the size of their own queue so they know 
    if they need to clear entries in their queue
    */
    function checkQueueSize()
      public
      view 
      contractActive()
      verifyUser()
      verifyQueueEmpty(msg.sender)
      returns (uint _queueSize)
    {
        return (resume_queues[userIDMaps[msg.sender]].length);
    }

    /* This function let's someone check the size of the resume of a user
    to see how many entries to look through to view entire resume of the user
    This function should be used before using viewResume function
    */
    function checkResumeSize(uint _UserID)
      public
      view 
      contractActive()
      verifyViewUserResume (_UserID)
      verifyResumeEmpty (_UserID)
      returns (uint _resumeSize)
    {
        return (resumes[_UserID].length);
    }  
    
    
    /* This function let's the owner check who is an admin
    */
    function isAdmin(address _adminAddr)
      public
      view 
      contractActive()
      onlyOwner()
      returns (bool) 
    {
        return (admins[_adminAddr]);
    }

    /* This function let's a user check their own userID
    */
    function checkUserID()
      public
      view 
      contractActive()
      verifyUser()
      returns (uint _UserID)
    {
        return (userIDMaps[msg.sender]);
    } 
      
    /* This function let's a user check when they signed up
    This uses an imported date time library
    */
    function checkSignUpDate()
      public
      view 
      contractActive()
      verifyUser()
      returns (uint _year, uint _month, uint _day)
    {
        uint _timestamp = users[userIDMaps[msg.sender]].date_joined;
        _year = BokkyPooBahsDateTimeLibrary.getYear(_timestamp);
        _month = BokkyPooBahsDateTimeLibrary.getMonth(_timestamp);
        _day = BokkyPooBahsDateTimeLibrary.getDay(_timestamp);
        return (
        _year
      , _month
      , _day);
    }

    /* This function displays owner
    */
    function showOwner()
      public
      view 
      contractActive()
      returns (address)
    {
        return (_owner);
    }

    // ////////////////////////////////////////////////////////////// //
    // /////////////////////// END OF FUNCTIONS ////////////////////////// //
    // ////////////////////////////////////////////////////////////// //

}
