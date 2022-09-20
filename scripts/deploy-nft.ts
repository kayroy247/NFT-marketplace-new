import { ethers } from "hardhat";

async function main() {
  const NFT = await ethers.getContractFactory("NFT");
  const nft = await NFT.deploy();
  await nft.deployed();

  const Marketplace = await ethers.getContractFactory("Marketplace");
  const marketplace = await Marketplace.deploy(1);
  await marketplace.deployed();

  console.log(`NFT contract deployed to ${nft.address}`);
  console.log(`Marketplace contract deployed to ${marketplace.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
