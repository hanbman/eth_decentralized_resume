var Resume = artifacts.require('Resume')

contract('Resume', function(accounts) {
    
    const owner = accounts[0]
    const alice = accounts[1]
    const bob = accounts[2]
    const emptyAddress = '0x0000000000000000000000000000000000000000'

    it("Admins should be able to add institutions.", async() => {
        const resume = await Resume.deployed()
        await resume.addAdmin(alice, {from: owner})
        
        const inst_name = "School of Hard Knocks"
        const type = 1
        const bob_added = await resume.addInstitution(inst_name, bob, type, {from: alice})

        assert.equal(bob_added.logs[0].event, "AddedInstitution", 'admin was unable to add an institution')
        assert.equal(bob_added.logs[0].args, 1, 'institution was added as with instution ID as 1')
    })
})