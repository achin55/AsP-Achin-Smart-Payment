// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
    AsP (Achin Smart Payment)
    Final Core Token Contract
    Founder: Achin Sahu Pranami
*/

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract AsPToken is ERC20, ERC20Burnable, Ownable, Pausable {



    uint256 public immutable MAX_SUPPLY = 100_000_000 * 10**18;
    uint256 public maxTxAmount;


    uint256 public feePercent;              
    address public feeWallet;

 

    bool public mintingPermanentlyDisabled;



    bool public tradingEnabled;

    // ---------------- EVENTS ----------------

    event TradingEnabled();
    event MintingDisabledForever();

    constructor()
        ERC20("Achin Smart Payment", "AsP")
        Ownable(msg.sender)
    {
        maxTxAmount = 100_000 * 10**18;
        feePercent = 2;
        feeWallet = msg.sender;

        _mint(msg.sender, 10_000_000 * 10**18);  // initial supply
    }

    // ================= OWNER CONTROLS =================

    function enableTrading() external onlyOwner {
        tradingEnabled = true;
        emit TradingEnabled();
    }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }

    function setFeePercent(uint256 _fee) external onlyOwner {
        require(_fee <= 5, "Fee too high");
        feePercent = _fee;
    }

    function setFeeWallet(address _wallet) external onlyOwner {
        feeWallet = _wallet;
    }

    function setMaxTxAmount(uint256 amount) external onlyOwner {
        maxTxAmount = amount;
    }

    function mint(address to, uint256 amount) external onlyOwner {
        require(!mintingPermanentlyDisabled, "Minting disabled forever");
        require(totalSupply() + amount <= MAX_SUPPLY, "Max supply exceeded");
        _mint(to, amount);
    }

    function disableMintingForever() external onlyOwner {
        mintingPermanentlyDisabled = true;
        emit MintingDisabledForever();
    }


    function _update(address from, address to, uint256 amount)
        internal
        override
        whenNotPaused
    {
        if (from != address(0) && to != address(0)) {

            require(tradingEnabled, "Trading not enabled");
            require(amount <= maxTxAmount, "Transfer exceeds limit");

            uint256 fee = (amount * feePercent) / 100;
            uint256 sendAmount = amount - fee;

            super._update(from, feeWallet, fee);
            super._update(from, to, sendAmount);
            return;
        }

        super._update(from, to, amount);
    }
}
