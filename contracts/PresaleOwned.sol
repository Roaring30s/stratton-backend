// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPolicy {
    function policy() external view returns (address);

    function renouncePolicy() external;

    function pushPolicy(address newOwner_) external;

    function pullPolicy() external;
}

contract Policy is IPolicy {
    address internal _owner;
    address internal _newOwner;

    event OwnershipPushed(
        address indexed previousOwner,
        address indexed newOwner
    );
    event OwnershipPulled(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
        emit OwnershipPushed(address(0), _owner);
    }

    function policy() public view override returns (address) {
        return _owner;
    }

    modifier onlyPolicy() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renouncePolicy() public virtual override onlyPolicy {
        emit OwnershipPushed(_owner, address(0));
        _owner = address(0);
    }

    function pushPolicy(address newOwner_) public virtual override onlyPolicy {
        require(
            newOwner_ != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipPushed(_owner, newOwner_);
        _newOwner = newOwner_;
    }

    function pullPolicy() public virtual override {
        require(msg.sender == _newOwner, "Ownable: must be new owner to pull");
        emit OwnershipPulled(_owner, _newOwner);
        _owner = _newOwner;
    }
}

contract PresaleOwned is Policy {
    address internal _presale;

    function setPresale(address presale_) external onlyPolicy returns (bool) {
        _presale = presale_;

        return true;
    }

    /**
     * @dev Returns the address of the current vault.
     */
    function presale() public view returns (address) {
        return _presale;
    }

    /**
     * @dev Throws if called by any account other than the vault.
     */
    modifier onlyPresale() {
        require(
            _presale == msg.sender,
            "PresaleOwned: caller is not the Presale"
        );
        _;
    }
}
