var Resume = artifacts.require('Resume')

contract('Resume', function(accounts) {
    
    const owner = accounts[0]
    const alice = accounts[1]
    const bob = accounts[2]
    const emptyAddress = '0x0000000000000000000000000000000000000000'

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
})