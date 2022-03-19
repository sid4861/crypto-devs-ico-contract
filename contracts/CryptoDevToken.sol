//SPDX-License-Identifer: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoDevs.sol";

contract CryptoDevToken is ERC20, Ownable {
    //price of one crypto dev token
    uint256 public constant tokenPrice = 0.001 ether;

    // Each NFT would give the user 10 tokens
    // It needs to be represented as 10 * (10 ** 18) as ERC20 tokens are represented by the smallest denomination possible for the token
    // By default, ERC20 tokens have the smallest denomination of 10^(-18). This means, having a balance of (1)
    // is actually equal to (10 ^ -18) tokens.
    // Owning 1 full token is equivalent to owning (10^18) tokens when you account for the decimal places.
    // More information on this can be found in the Freshman Track Cryptocurrency tutorial.

    uint256 public constant tokensPerNFT = 10 * 10**18;

    uint256 public constant maxTokenSupply = 10000 * 10**18;

    // CryptoDevsNFT contract instance
    ICryptoDevs CryptoDevsNFT;

    // Mapping to keep track of which tokenIds have been claimed
    mapping(uint256 => bool) public tokenIdsClaimed;

    constructor(address _cryptoDevsContract) ERC20("Crypto Dev Token", "CD") {
        CryptoDevsNFT = ICryptoDevs(_cryptoDevsContract);
    }

    /**
     * @dev Mints `amount` number of CryptoDevTokens
     * Requirements:
     * - `msg.value` should be equal or greater than the tokenPrice * amount
     */

    function mint(uint256 amount) public payable {
        //token ether required to buy the amount of tokens
        uint256 _requiredAmount = amount * tokenPrice;
        require(msg.value >= _requiredAmount, "Not enough ether to buy tokens");

        uint256 amountWithDecimals = amount * 10**18;
        require((totalSupply() + amountWithDecimals) <= maxTokenSupply);
        _mint(msg.sender, amountWithDecimals);
    }

    function claim() public {
        address sender = msg.sender;

        //number of NFTs owned by sender;
        uint256 balance = CryptoDevsNFT.balanceOf(sender);

        require(balance > 0, "The sender does not own any NFTs");

        //count of unclaimedTokenIds - NFTs that sender owns for which she has not claimed tokens
        uint256 countOfUnclaimedTokenIds = 0;

        for(uint256 i = 0; i<balance; i++) {
            uint256 tokenId = CryptoDevsNFT.tokenOfOwnerByIndex(sender, i);
            if(!tokenIdsClaimed[tokenId]) {
                countOfUnclaimedTokenIds += 1;
                tokenIdsClaimed[tokenId] = true;
            }
        }

        require(countOfUnclaimedTokenIds > 0, "no unclaimed NFTs");

        _mint(sender, countOfUnclaimedTokenIds * tokensPerNFT);
    }

    receive() external payable {}
    fallback() external payable {}
}
