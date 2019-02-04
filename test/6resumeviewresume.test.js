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
    
      describe("Test 6", function() {
        beforeEach(deploy);

        it("Outside parties should be able to view user's resume.", async() => { 
            //deploy the contract
            const resume = await Resume.deployed()
            //owner adds alice as admin
            await resume.addAdmin(alice, {from: owner})
            //set parameters of institution
            const inst_name = "School of Hard Knocks"
            const type = 1
            //alice adds bob as an institution
            await resume.addInstitution(inst_name, bob, type, {from: alice})

            //owner sets the sign up fee for new users
            const fee = 10
            await resume.setSignUpFee(fee, {from: owner})

            //ashley signs up and pays the sign up fee
            const name = "Ashley"
            const amount = 10
            await resume.signUpUser(name, {from: ashley, value: amount})

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
            
            //ashley can now approve the items in her queue after viewing them
            const _entryID = 3
            const _doYouWantToApprove = true
            const approve_entry = await resume.approveEntry(_entryID, _doYouWantToApprove, {from: ashley})
            
            //now a third party such as an employer can view Ashley's resume 
            //first they can view the size of ashley's resume
            //then they can choose which number of element of the entry they want to view
            //all of these entries only enter her resume after they have been approved
            const _UserID = 2
            const _entryElement = 0
            const resumeSize = await resume.checkResumeSize(_UserID, {from: employer})
            const ashleysResume = await resume.viewResume(_UserID, _entryElement, {from: employer})

            assert.equal(resumeSize, 2, 'resume size is not 2')
            assert.equal(ashleysResume.entry_title, _entry_title, 'entry title does not match')
            assert.equal(ashleysResume.degree_descr, _degree_descr, 'degree description does not match')
            assert.equal(ashleysResume.institution_name, inst_name, 'institution name does not match')
        })

    })

})