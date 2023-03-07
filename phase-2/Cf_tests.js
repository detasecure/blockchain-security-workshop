const { expect } = require("chai");
const hre = require("hardhat");
const { ethers} = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");

describe("Coin Flip Contract",function(){

     let coinflip;
     let owner;
     let addr1;
     let CF;
     
     beforeEach(async function () {
          [owner, addr1] = await ethers.getSigners();
          const CF = await hre.ethers.getContractFactory("CoinFlip");
          coinflip = await CF.deploy();;
     });


     it("Owner can deposit money", async () => {
          await coinflip.depositBalance({ value: ethers.utils.parseEther("10") });
          expect(await coinflip.getBalance()).to.equal(ethers.utils.parseEther("10"));          
     })

     it("User can play game", async () => {
          await coinflip.depositBalance({ value: ethers.utils.parseEther("10") });
          console.log(await ethers.provider.getBalance(addr1.address));
          await coinflip.connect(addr1).flipCoin({ value: ethers.utils.parseEther("5")});
          console.log(await ethers.provider.getBalance(addr1.address));
     })

     it("User cannot deposit less than 1 ether ", async () => {
          await coinflip.depositBalance({ value: ethers.utils.parseEther("10") });
          await expect(coinflip.connect(addr1).flipCoin({ value: ethers.utils.parseEther("0.5")})).to.be.revertedWith("Minimum bet is 1 ether.");
     })

     it("User cannot call the function without any money", async () => {
          await coinflip.depositBalance({ value: ethers.utils.parseEther("10") });
          await expect(coinflip.connect(addr1).flipCoin()).to.be.reverted;
     })

     it("Game cannot be played if there isn't enough balnce", async () => {
          await coinflip.depositBalance({ value: ethers.utils.parseEther("10") });
          await expect(coinflip.connect(addr1).flipCoin({ value: ethers.utils.parseEther("6")})).to.be.reverted;
     })

     it("Only the owner can withdraw money", async () => {
          await coinflip.depositBalance({ value: ethers.utils.parseEther("10") });
          await coinflip.connect(addr1).flipCoin({ value: ethers.utils.parseEther("4")});
          await coinflip.withdrawBalance();
          expect(await coinflip.getBalance()).to.equal(0);
     })

     
})
