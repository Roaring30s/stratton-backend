// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./ERC20.sol";
import "./IpBWD.sol";

contract StrattonPresale is Ownable {
    struct UserInfo {
        uint256 pBWDPurchased;
    }

    uint256 public userpBWDCap = 50 * 1e18;
    uint256 public priceDAI = 50 * 1e18;

    uint256 public maxSupply = 20000 * 1e18;

    IERC20 public DAI;
    IERC20 public pBWD;

    address public DAO; // Multisig treasury to send proceeds to

    uint256 public totalRaisedDAI; // total DAI raised by sale

    bool public started; // true when sale is started

    bool public ended; // true when sale is ended

    bool public contractPaused; // circuit breaker

    mapping(address => UserInfo) public userInfo;

    event Deposit(address indexed who, uint256 amount);
    event SaleStarted(uint256 block);
    event SaleEnded(uint256 block);
    event ClaimUnlocked(uint256 block);
    event AdminWithdrawal(address token, uint256 amount);

    constructor(
        address _pBWD,
        address _DAI,
        address _DAO
    ) {
        require(_pBWD != address(0));
        pBWD = IERC20(_pBWD);
        require(_DAI != address(0));
        DAI = IERC20(_DAI);
        require(_DAO != address(0));
        DAO = _DAO;
    }

    /**
     * @notice modifer to check if contract is paused
     */
    modifier checkIfPaused() {
        require(contractPaused == false, "contract is paused");
        _;
    }

    /**
     * @notice Starts the sale
     */
    function start() external onlyOwner {
        require(!started, "Sale has already started");
        started = true;
        emit SaleStarted(block.number);
    }

    /**
     * @notice Ends the sale
     */
    function end() external onlyOwner {
        require(started, "Sale has not started");
        require(!ended, "Sale has already ended");
        ended = true;
        emit SaleEnded(block.number);
    }

    /**
     * @notice lets owner pause contract
     */
    function togglePause() external onlyOwner returns (bool) {
        contractPaused = !contractPaused;
        return contractPaused;
    }

    /**
     *  @notice transfer ERC20 token to DAO multisig
     *  @param _token: token address to withdraw
     *  @param _amount: amount of token to withdraw
     */
    function adminWithdraw(address _token, uint256 _amount) external onlyOwner {
        IERC20(_token).transfer(address(msg.sender), _amount);
        emit AdminWithdrawal(_token, _amount);
    }

    /**
     *  @notice it deposits DAI for the sale
     *  @param _amount: amount of DAI to deposit to sale (18 decimals)
     */
    function deposit(uint256 _amount) external checkIfPaused {
        require(started, "Sale has not started");
        require(!ended, "Sale has ended");
        require(
            IpBWD(address(pBWD)).totalSupply() < maxSupply,
            "pBWD is sold out"
        );

        uint256 pBWDPurchaseAmount = (_amount * 1e18) / priceDAI;

        UserInfo storage user = userInfo[msg.sender];

        require(
            userpBWDCap >= user.pBWDPurchased + pBWDPurchaseAmount,
            "pBWD amount exceeds allocation"
        );

        require(
            pBWDPurchaseAmount == 10e18 ||
                pBWDPurchaseAmount == 20e18 ||
                pBWDPurchaseAmount == 30e18 ||
                pBWDPurchaseAmount == 40e18 ||
                pBWDPurchaseAmount == 50e18,
            "Purchase amount should be one of 10, 20, 30, 40 or 50 pBWD"
        );

        totalRaisedDAI = totalRaisedDAI + _amount;
        user.pBWDPurchased = user.pBWDPurchased + pBWDPurchaseAmount;

        DAI.transferFrom(msg.sender, DAO, _amount);

        IpBWD(address(pBWD)).mint(msg.sender, pBWDPurchaseAmount);

        emit Deposit(msg.sender, _amount);
    }

    /**
     * @notice it checks a users pBWD allocation remaining
     * @param _user - EOA address
     * @return {uint256} remaining pBWD left to purchase
     */
    function getUserRemainingAllocation(address _user)
        external
        view
        returns (uint256)
    {
        UserInfo memory user = userInfo[_user];
        return userpBWDCap - user.pBWDPurchased;
    }
}
