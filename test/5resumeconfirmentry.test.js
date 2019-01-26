//Test #5- This test verifies that the user can confirm or reject the entries in their queue

var Resume = artifacts.require('Resume')

contract('Resume', function(accounts) {
    
    const owner = accounts[0]
    const alice = accounts[1]
    const bob = accounts[2]
    const ashley = accounts[3]
    const emptyAddress = '0x0000000000000000000000000000000000000000'

    const deploy = async function() {
        resume = await Resume.new();
      };
    
      describe("Test 5", function() {
        beforeEach(deploy);

        it("Users should be able to confirm entries in their queue into their resume.", async() => { 
            //deploy the contract
            const resume = await Resume.deployed()
            //owner adds alice as admin
            //await resume.addAdmin(alice, {from: owner})
            //set parameters of institution
            //const inst_name = "School of Hard Knocks"
            //const type = 1
            //alice adds bob as an institution
            //await resume.addInstitution(inst_name, bob, type, {from: alice})

            //owner sets the sign up fee for new users
            //const fee = 10
            //await resume.setSignUpFee(fee, {from: owner})

            //ashley signs up and pays the sign up fee
            //const name = "Ashley"
            //const amount = 10
            //await resume.signUpUser(name, {from: ashley, value: amount})

            //bob the institution creates an entry for ashley's resume
            //this entry will reside in ashley's resume queue awaiting ashley's approval
            //set the parameters of the entry
            //const _entry_title = "PhD"
            //const _degree_descr = "Triple major- psychology, economics, CS"
            //start and end date are unix datetimes
            //const _start_date = 1
            //const _end_date = 1000
            //entry type can be degree or certificate
            //const _etype = 0
            //const _review = "barely passed"
            //add_entry = await resume.addEntry(ashley, _entry_title, _degree_descr, _start_date, _end_date, _etype, _review, {from: bob})
            
            //ashley can now check the size of her queue and see entries in her queue
            //const queue_size = await resume.checkQueueSize({from: ashley})
            //const queue = await resume.showMyResumeQueue({from: ashley})
            
            //ashley can now approve the items in her queue after viewing them
            const _entryID = 1
            const _doYouWantToApprove = true
            const approve_entry = await resume.approveEntry(_entryID, _doYouWantToApprove, {from: ashley})
            
            assert.equal(approve_entry.logs[0].event, "AddedtoResume", 'an entry was unable to be added to resume')
            assert.equal(approve_entry.logs[0].args.EntryID, 1, 'EntryID #1 not added to resume')
        })

    })

})