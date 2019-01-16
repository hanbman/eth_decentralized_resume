var Resume = artifacts.require('Resume')

contract('Resume', function(accounts) {
    
    const owner = accounts[0]
    const alice = accounts[1]
    const bob = accounts[2]
    const emptyAddress = '0x0000000000000000000000000000000000000000'

    it("owner of the contract should be able to sign up admins", async() => {
        const resume = await Resume.deployed()

        const alice_added = await resume.addAdmin(alice, {from: owner})
        const alice_admin = await resume.admins(alice, {from: owner})

        assert.equal(alice_added, true, 'owner was unable to add an admin')
        assert.equal(alice_admin, true, 'alice was not added as admin')
    })
})