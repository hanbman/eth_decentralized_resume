var Resume = artifacts.require('Resume')

contract('Resume', function(accounts) {
    
    const owner = accounts[0]
    const alice = accounts[1]
    const bob = accounts[2]
    const ashley = accounts[3]
    const emptyAddress = '0x0000000000000000000000000000000000000000'

    it("Owner should be able to set the sign up fee. User should be able to sign up.", async() => {
        var ashleyBalanceBefore = await web3.eth.getBalance(ashley)
        
        const resume = await Resume.deployed()
        await resume.addAdmin(alice, {from: owner})
        const inst_name = "School of Hard Knocks"
        const type = 1
        await resume.addInstitution(inst_name, bob, type, {from: alice})

        const fee = 10
        set_fee = await resume.setSignUpFee(fee, {from: owner})

        const name = "Ashley"
        const amount = 10
        sign_up = await resume.signUpUser(name, {from: ashley, value: amount})

        var ashleyBalanceAfter = await web3.eth.getBalance(ashley)

        assert.equal(set_fee.logs[0].event, "SignUpFeeSet", 'owner was unable to set the fee')
        assert.equal(set_fee.logs[0].args.fee, 10, 'fee was not set to 10')

        assert.equal(sign_up.logs[0].event, "AddedUser", 'user was unable to sign up')
        assert.equal(sign_up.logs[0].args.UserID, 1, 'user was not set with ID = 1')
        assert.notEqual(parseInt(ashleyBalanceBefore), parseInt(ashleyBalanceBefore), 'user was not charged sign up fee')
    })
})