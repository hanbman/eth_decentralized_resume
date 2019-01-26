# Avoiding Common Attacks

#### 1. Integer Arithmetic Overflow
In order to prevent common integer overflow issues, the common library SafeMath was implemented for arithmetic operations. 

#### 2. Public/Private/Restricted Functions
Functions were restricted access by user type such as Owner for adding Admins, Admins for adding Institutions, Owners for emergency stops and changing the sign up fee, etc. Functions that could be restricted to view functions were done when possible. Variables were kept private when appropriate.

#### 3. Gas Limits for Infinite / Large Looping
Returning objects of unknown size or using for loops were avoided at all cost. Viewing resume queues and resumes were restricted to a single entry returned.

#### 4. Accepting User Inputs
Users were restricting to only viewing and approving the first item in their queues so they had to address the oldest entries first and do so in chronological order. Users were required to enter the EntryID for the entry they wanted to approve/reject, but it was required that the entry ID matches the first item in their queue. This gave an extra layer of protection that the User had viewed the entry in the queue, retrieved it, and was aware of which item they were approving/rejecting before doing so.

#### 5. Timestamp Vulnerabilities
A library to handle timestamps was added and a function created so Users can check their own sign up date. This gives some functionality to check the human readable datetime for their sign up onto the system.

#### 6. Powerful Contract Administrators
There is a separation of power and levels of approval required between the Owner, Admin, and Institution. Only the owner can add Admins, and both Owners and Admins can add Institutions, but only Institutions can create entries. This separates the power of assigning capabilities and those who actually create the entries themselves. There is also a queue for staging entries before approval to give an extra layer of protection for Users to vet entries before they are permanently added to their resumes. 

#### 7. TX.Origin Problem
msg.sender was always used rather than tx.origin


