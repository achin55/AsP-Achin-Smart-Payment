// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract AsPToken is ERC20, Ownable, Pausable {

    uint256 public immutable MAX_SUPPLY;
    uint256 public maxTxAmount;

    mapping(address => bool) public blacklisted;

    constructor() ERC20("Achin Startup Project", "AsP") Ownable(msg.sender) {
        MAX_SUPPLY = 1_000_000 * 10 ** decimals();
        maxTxAmount = MAX_SUPPLY / 50; // 2% max tx

        _mint(msg.sender, MAX_SUPPLY);
    }

    // -------- ADMIN CONTROLS --------

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function setMaxTxAmount(uint256 amount) external onlyOwner {
        maxTxAmount = amount;
    }

    function blacklist(address user, bool status) external onlyOwner {
        blacklisted[user] = status;
    }

    // -------- TRANSFER LOGIC --------

    function _update(address from, address to, uint256 amount)
        internal
        override
        whenNotPaused
    {
        require(!blacklisted[from] && !blacklisted[to], "Blacklisted");

        if (from != address(0) && to != address(0)) {
            require(amount <= maxTxAmount, "Max tx exceeded");
        }

        super._update(from, to, amount);
    }
}
