// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AsPPresale is Ownable, ReentrancyGuard {

    IERC20 public aspToken;

    uint256 public constant TOKENS_PER_ETH = 10000;
    uint256 public constant MAX_PRESALE_TOKENS = 300000 * 10**18;

    uint256 public tokensSold;
    bool public presaleActive;

    event TokensPurchased(address indexed buyer, uint256 ethSpent, uint256 tokensReceived);
    event PresaleStarted();
    event PresaleStopped();

    constructor(address _aspToken) Ownable(msg.sender) {
        aspToken = IERC20(_aspToken);
    }

    // ---------------- ADMIN ----------------

    function startPresale() external onlyOwner {
        presaleActive = true;
        emit PresaleStarted();
    }

    function stopPresale() external onlyOwner {
        presaleActive = false;
        emit PresaleStopped();
    }

    function withdrawUnsoldTokens() external onlyOwner {
        uint256 remaining = aspToken.balanceOf(address(this));
        require(remaining > 0, "No tokens left");
        aspToken.transfer(owner(), remaining);
    }

    // ---------------- BUY TOKENS ----------------

    function buyTokens() public payable nonReentrant {
        require(presaleActive, "Presale not active");
        require(msg.value > 0, "Send ETH");

        uint256 tokensToBuy = msg.value * TOKENS_PER_ETH;
        require(tokensSold + tokensToBuy <= MAX_PRESALE_TOKENS, "Presale cap reached");

        tokensSold += tokensToBuy;

        aspToken.transfer(msg.sender, tokensToBuy);

        payable(owner()).transfer(msg.value);

        emit TokensPurchased(msg.sender, msg.value, tokensToBuy);
    }

    // fallback
    receive() external payable {
        buyTokens();
    }
}
