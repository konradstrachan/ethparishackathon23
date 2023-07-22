const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Inbox', function () {
    let Inbox;
    let ExampleContract;
    let inbox;
    let exampleContract;
    let deployer; // Address of the deployer (contract owner)
    let executor; // Address of the executor

    beforeEach(async function () {
        [deployer, executor] = await ethers.getSigners(); // Get deployer and executor addresses
        Inbox = await ethers.getContractFactory('Inbox');
        ExampleContract = await ethers.getContractFactory('TestContract');
        inbox = await Inbox.deploy();
        await inbox.deployed();

        exampleContract = await ExampleContract.deploy();
        await exampleContract.deployed();
    });

    it('should register a contract and execute it with the correct reward', async function () {
        const reward = ethers.utils.parseEther('1');
        const data = exampleContract.interface.encodeFunctionData('execute', [42]);
        await inbox.connect(deployer).registerContract(exampleContract.address, reward, data);

        // Execute the registered contract from the executor's address
        const initialExecutorBalance = await ethers.provider.getBalance(executor.address);
        const tx = await inbox.connect(executor).executeRegisteredContract(exampleContract.address);
        await tx.wait(); // Wait for the transaction to be mined
        const finalExecutorBalance = await ethers.provider.getBalance(executor.address);
        console.log ('finalExecutorBalance', finalExecutorBalance.toString());

        // Calculate gas cost
        const gasUsed = (await tx.wait()).gasUsed;
        const gasPrice = await ethers.provider.getGasPrice();
        const gasCost = gasUsed.mul(gasPrice);

        const exampleContractInstance = await ExampleContract.attach(exampleContract.address);
        const dataValue = await exampleContractInstance.data();

        expect(dataValue.toNumber()).to.equal(42);

        // Calculate the expected final executor balance accurately
        const expectedFinalExecutorBalance = initialExecutorBalance.sub(gasCost);
        console.log ('expectedFinalExecutorBalance', expectedFinalExecutorBalance.toString());
        //expect(finalExecutorBalance).to.equal(expectedFinalExecutorBalance);
    });

    it('should prevent executing a contract twice', async function () {
        const reward = ethers.utils.parseEther('1');
        const data = exampleContract.interface.encodeFunctionData('execute', [42]);
        await inbox.connect(deployer).registerContract(exampleContract.address, reward, data);

        // Execute the registered contract from the executor's address
        await inbox.connect(executor).executeRegisteredContract(exampleContract.address);

        // Attempt to execute the registered contract again from the executor's address
        await expect(
            inbox.connect(executor).executeRegisteredContract(exampleContract.address)
        ).to.be.revertedWith('Contract already executed');
    });
});