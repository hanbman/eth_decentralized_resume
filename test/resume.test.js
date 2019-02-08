//Test #6- This test verifies that third parties can view a resume entry from
//a specified user and their entry element

var Resume = artifacts.require('Resume')

contract('Resume', function(accounts) {
    
    const owner = accounts[0]
    const alice = accounts[1]
    const bob = accounts[2]
    const ashley = accounts[3]
    const employer = accounts[4]
    const emptyAddress = '0x0000000000000000000000000000000000000000'

    const deploy = async function() {
        resume = await Resume.new();
      };
    
      describe("Tests", function() {
        beforeEach(deploy);

        it("Owner of the contract should be able to sign up admins, and verify who is an admin.", async() => {
            //Deploy contract
            const resume = await Resume.deployed()

            //Owner adds alice as an admin
            const alice_added = await resume.addAdmin(alice, {from: owner})
            //Owner checks if alice is added as an admin
            const alice_admin = await resume.isAdmin(alice, {from: owner})

            assert.equal(alice_added.logs[0].event, "AddedAdmin", 'owner was unable to add an admin')
            assert.equal(alice_admin, true, 'alice was not added as admin')
        })

        it("Admins should be able to add institutions.", async() => {
            //deploy contract
            const resume = await Resume.deployed()
            
            //set institution parameters
            const inst_name = "School of Hard Knocks"
            const type = 1
            //alice adds bob as an institution with type=1 (school)
            const bob_added = await resume.addInstitution(inst_name, bob, type, {from: alice})

            assert.equal(bob_added.logs[0].event, "AddedInstitution", 'admin was unable to add an institution')
            assert.equal(bob_added.logs[0].args.UniversityID, 1, 'institution was not added with instution ID as 1')
        })
        
        it("Owner should be able to set the sign up fee. User should be able to sign up.", async() => {
            //verify ashley's ether balance before transactions
            var ashleyBalanceBefore = await web3.eth.getBalance(ashley)
            
            //deploy the contract
            const resume = await Resume.deployed()

            //owner sets the sign up fee for new users
            const fee = 10
            set_fee = await resume.setSignUpFee(fee, {from: owner})

            //ashley signs up and pays the sign up fee
            const name = "Ashley"
            const amount = 10
            sign_up = await resume.signUpUser(name, {from: ashley, value: amount})

            //record ashley's balance after the transactions
            var ashleyBalanceAfter = await web3.eth.getBalance(ashley)

            assert.equal(set_fee.logs[0].event, "SignUpFeeSet", 'owner was unable to set the fee')
            assert.equal(set_fee.logs[0].args.fee, 10, 'fee was not set to 10')

            assert.equal(sign_up.logs[0].event, "AddedUser", 'user was unable to sign up')
            assert.equal(sign_up.logs[0].args.UserID, 1, 'user was not set with ID = 1')
            assert.notEqual(parseInt(ashleyBalanceBefore), parseInt(ashleyBalanceAfter), 'user was not charged sign up fee')
        })

        it("Institution should be able to add entry to user's queue. User should be able to view queue.", async() => { 
            //deploy the contract
            const resume = await Resume.deployed()

            //bob the institution creates an entry for ashley's resume
            //this entry will reside in ashley's resume queue awaiting ashley's approval
            //set the parameters of the entry
            const _entry_title = "PhD"
            const _degree_descr = "Triple major- psychology, economics, CS"
            //start and end date are unix datetimes
            const _start_date = 1
            const _end_date = 1000
            //entry type can be degree or certificate
            const _etype = 0
            const _review = "barely passed"
            add_entry = await resume.addEntry(ashley, _entry_title, _degree_descr, _start_date, _end_date, _etype, _review, {from: bob})
            
            //ashley can now check the size of her queue and see entries in her queue
            const queue_size = await resume.checkQueueSize({from: ashley})
            const queue = await resume.showMyResumeQueue({from: ashley})
            
            assert.equal(add_entry.logs[0].event, "EntryCreated", 'institution was unable to create entry')
            assert.equal(add_entry.logs[0].args.EntryID, 1, 'EntryID not set to 1')

            assert.equal(queue_size, 1, 'entry was not added to queue')
            assert.equal(queue.entryID, 1, 'entryID of 1 was not added to users queue')
            assert.equal(queue.entry_title, _entry_title, 'entry title was not added correctly')
            assert.equal(queue.degree_descr, _degree_descr, 'degree description was not added correctly')
            assert.equal(queue.review, _review, 'review was not added correctly')
        })

        it("Users should be able to confirm entries in their queue into their resume.", async() => { 
            //deploy the contract
            const resume = await Resume.deployed()

            //ashley can now approve the items in her queue after viewing them
            const _entryID = 1
            const _doYouWantToApprove = true
            const approve_entry = await resume.approveEntry(_entryID, _doYouWantToApprove, {from: ashley})
            
            assert.equal(approve_entry.logs[0].event, "AddedtoResume", 'an entry was unable to be added to resume')
            assert.equal(approve_entry.logs[0].args.EntryID, 1, 'EntryID #1 not added to resume')
        })

        it("Outside parties should be able to view user's resume.", async() => { 
            //deploy the contract
            const resume = await Resume.deployed()
            
            //now a third party such as an employer can view Ashley's resume 
            //first they can view the size of ashley's resume
            //then they can choose which number of element of the entry they want to view
            //all of these entries only enter her resume after they have been approved
            const _UserID = 1
            const _entryElement = 0
            const resumeSize = await resume.checkResumeSize(_UserID, {from: employer})
            const ashleysResume = await resume.viewResume(_UserID, _entryElement, {from: employer})

            const _entry_title = "PhD"
            const _degree_descr = "Triple major- psychology, economics, CS"
            const inst_name = "School of Hard Knocks"
            
            assert.equal(resumeSize, 1, 'resume size is not 1')
            assert.equal(ashleysResume.entry_title, _entry_title, 'entry title does not match')
            assert.equal(ashleysResume.degree_descr, _degree_descr, 'degree description does not match')
            assert.equal(ashleysResume.institution_name, inst_name, 'institution name does not match')
        })

    })

})