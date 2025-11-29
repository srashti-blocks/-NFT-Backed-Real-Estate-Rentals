// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
    NFT-Backed Real-Estate Rentals
*/

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract RealEstateNFT is ERC721, Ownable {

    struct Property {
        uint256 rentPerMonth;
        address currentTenant;
        uint256 rentPaidTill;
    }

    uint256 public nextTokenId;
    mapping(uint256 => Property) public properties;

    // ✅ FIX: Pass owner to Ownable constructor
    constructor() ERC721("RealEstateRentalNFT", "RER") Ownable(msg.sender) {}

    // --------------------------------------------------
    // Function 1: Mint Property NFT
    // --------------------------------------------------
    function mintProperty(address to, uint256 rentPerMonth) external onlyOwner {
        uint256 tokenId = nextTokenId++;
        _safeMint(to, tokenId);

        properties[tokenId] = Property({
            rentPerMonth: rentPerMonth,
            currentTenant: address(0),
            rentPaidTill: 0
        });
    }

    // --------------------------------------------------
    // Function 2: Rent Property
    // --------------------------------------------------
    function rentProperty(uint256 tokenId) external payable {
        Property storage prop = properties[tokenId];
        require(msg.value == prop.rentPerMonth, "Incorrect rent amount");
        require(ownerOf(tokenId) != msg.sender, "Owner cannot rent their own property");

        if (prop.currentTenant == address(0)) {
            prop.currentTenant = msg.sender;
        }

        require(prop.currentTenant == msg.sender, "Not authorized tenant");

        prop.rentPaidTill += 30 days;
    }

    // --------------------------------------------------
    // Function 3: Owner Withdraw Rent
    // --------------------------------------------------
    function withdrawRent() external onlyOwner {
        uint256 amount = address(this).balance;
        require(amount > 0, "No rent to withdraw");

        payable(msg.sender).transfer(amount);
    }
}

