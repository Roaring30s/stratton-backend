// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PresaleOwned.sol";
import "./ERC20Permit.sol";

contract pBWD is ERC20Permit, PresaleOwned {
    bool transferable = false;

    constructor() ERC20("Pre BWD", "pBWD", 18) ERC20Permit() {}

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        require(transferable, "Cannot be transferred");
        return super.transfer(recipient, amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public virtual override returns (bool) {
        require(transferable, "Cannot be transferred");
        return super.transferFrom(from, to, value);
    }

    function mint(address account_, uint256 amount_) external onlyPresale {
        _mint(account_, amount_);
    }

    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(msg.sender, amount);
    }

    /*
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */

    function burnFrom(address account_, uint256 amount_) public virtual {
        _burnFrom(account_, amount_);
    }

    function _burnFrom(address account_, uint256 amount_) public virtual {
        uint256 decreasedAllowance_ = allowance(account_, msg.sender) - amount_;
        _approve(account_, msg.sender, decreasedAllowance_);
        _burn(account_, amount_);
    }
}
