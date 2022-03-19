const { ethers } = require("hardhat");
const { CRYPTO_DEVS_NFT_CONTRACT_ADDRESS } = require("../constants");
require("dotenv").config({ path: ".env" });

const main = async () => {
    try {
        const cryptoDevsNFTContract = CRYPTO_DEVS_NFT_CONTRACT_ADDRESS;
        const contractFactory = await ethers.getContractFactory("CryptoDevToken");
        const contract = await contractFactory.deploy(cryptoDevsNFTContract);
        await contract.deployed();

        console.log(contract.address);

    } catch (error) {
        console.log(error);
    }
}

main()
    .then(() => process.exit(0))
    .catch(err => process.exit(1)) 