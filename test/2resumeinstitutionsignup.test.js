var Resume = artifacts.require('Resume')

contract('Resume', function(accounts) {
    
    const owner = accounts[0]
    const alice = accounts[1]
    const bob = accounts[2]
    const emptyAddress = '0x0000000000000000000000000000000000000000'

    const deploy = async function() {
        resume = await Resume.new();
      };

      describe("Test 2", function() {
        beforeEach(deploy);
        
        it("Admins should be able to add institutions.", async() => {
            //deploy contract
            const resume = await Resume.deployed()
            //owner adds alice as an admin
            //await resume.addAdmin(alice, {from: owner})
            
            //set institution parameters
            const inst_name = "School of Hard Knocks"
            const type = 1
            //alice adds bob as an institution with type=1 (school)
            const bob_added = await resume.addInstitution(inst_name, bob, type, {from: alice})

            assert.equal(bob_added.logs[0].event, "AddedInstitution", 'admin was unable to add an institution')
            assert.equal(bob_added.logs[0].args.UniversityID, 1, 'institution was not added with instution ID as 1')
        })
    })
})