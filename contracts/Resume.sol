pragma solidity ^0.5.0;

contract Resume {

  // ////////////////////////////////////////////////////////////// //
  // /////////////////////// VARIABLES ////////////////////////// //
  // ////////////////////////////////////////////////////////////// //

  /* set owner */
  address owner;

  /* keep track of the users, institutions, and entries */
  uint UserCount;
  uint InstitutionCount;
  uint EntryCount;

  /* keep a list of Admins that can add universities, users, entries
  mapping(address => bool) admins;

  // ///////////////////////     USERS    ////////////////////////// //

  /* Creating a public mapping that maps the UserID (a number) to a User. */
    
  mapping (uint => User) public users;

  /* Creating a struct named User. 
  Can expand more details about the User in the future- 
  address, age, etc
  */
  
  struct User {
        string name;
        string date_joined;
        address payable userAddr;
    }

  // ////////////////////////////////////////////////////////////// //


  // /////////////////////// INSTITUTIONS ////////////////////////// //

  /* Creating a public mapping that maps the InstitutionID (a number) to an Instituion. */
    
  mapping (uint => Institution) public institutions;

  /* Creating an enum called Type for types of institutions */
  
  enum Type {University, School, Certificator}

  /* Creating a struct named Institution. 
  Can expand more details about the Institution in the future- 
  address, year of inception, etc
  */
  
  struct Institution {
        string name;
        string date_joined;
        Type type;
        address payable institutionAddr;
    }

  // ////////////////////////////////////////////////////////////// //
  

  // /////////////////////// RESUMES ////////////////////////// //

  /* Creating a public mapping that maps the UserID (a number) to a resume.
  Each user is mapped to one resume, and joined using UserID
   */
    
  mapping (uint => Resume) public resumes;

  /* Each resume is an array of unique entryids that string together a single resume
   */

  uint[] Resume;

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
  
  enum Type {Degree, Certificate}
  
  /* struct of the entry containing info about the individual entry
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
        bool approved;
        string entry_title;
        string degree_descr;
        uint institutionID;
        string date_received;
        string start_date;
        string end_date;
        Type type;
        string review;
    }

  // ////////////////////////////////////////////////////////////// //
  

  // ////////////////////////////////////////////////////////////// //
  // /////////////////////// END OF VARIABLES ////////////////////////// //
  // ////////////////////////////////////////////////////////////// //
  
  
  
  // ////////////////////////////////////////////////////////////// //
  // /////////////////////// EVENTS ////////////////////////// //
  // ////////////////////////////////////////////////////////////// //

  /* Create events*/

    event AddedAdmin(address adminAddr);
    event AddedInstitution(uint UniversityID);
    event AddedUser(uint UserID);
    event EntryCreated(uint EntryID);
    event AddedtoResume(uint EntryID, uint UserID);

  // ////////////////////////////////////////////////////////////// //
  // /////////////////////// END OF EVENTS ////////////////////////// //
  // ////////////////////////////////////////////////////////////// //


  // ////////////////////////////////////////////////////////////// //
  // /////////////////////// MODIFIERS ////////////////////////// //
  // ////////////////////////////////////////////////////////////// //

    /* A modifer that checks if the msg.sender is the the right address */
    // Do not forget the "_;"! It will
    // be replaced by the actual function
    // body when the modifier is used.
  
  modifier verifyAdmin () 
    { 
      require (Admin(msg.sender)==true, "This action is prohibited for non Admins.");
      _;
    }
  
  modifier verifyCaller (address _address) 
    { 
      require (msg.sender == _address, "Message sender is not correct.");
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
    owner=msg.sender;
    admin[owner]=true;
    UserCount=1;
    InstitutionCount=1;
    EntryCount=1;
  }

  //function addAdmin(address admin)
  
  /* This function let's users sign up for this service to record their resumes */
  function signUpUser(string _name)
  public
  returns(bool)
  {
    users[UserCount] = User({name: _name, date_joined: now, userAddr: msg.sender});
    emit AddedUser(UserCount);
    UserCount = UserCount + 1;
    return true;
  }

  /* This function let's admins add institutions that are legitimate */
  function addInstitution(string _name, address _institutionAddr, Type _type) 
  public
  verifyAdmin()
  returns(bool)
  {
    institutions[InstitutionCount] = Institution({name: _name, date_joined: now, type: _type, institutionAddr=_institutionAddr});
    emit AddedInstitution(InstitutionCount)
    InstitutionCount = InstitutionCount + 1;
    return true;
  }

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

  // ////////////////////////////////////////////////////////////// //
  // /////////////////////// END OF FUNCTIONS ////////////////////////// //
  // ////////////////////////////////////////////////////////////// //

}
