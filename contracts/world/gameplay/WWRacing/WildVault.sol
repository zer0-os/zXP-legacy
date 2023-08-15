pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WildVault {
    IERC20 public token; // The token we're accepting
    address public controller; // The only address that can withdraw the token

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    modifier onlyController() {
        require(msg.sender == controller, "Not the controller");
        _;
    }

    constructor(address _token, address _controller) {
        token = IERC20(_token);
        controller = _controller;
    }

    function deposit(uint256 amount) external {
        require(amount > 0, "Amount should be greater than 0");

        // Transfer the tokens to this contract
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );

        emit Deposited(msg.sender, amount);
    }

    function withdraw(uint256 amount) external onlyController {
        require(
            amount <= token.balanceOf(address(this)),
            "Not enough tokens in the vault"
        );

        // Transfer the tokens from this contract to the controller
        require(token.transfer(controller, amount), "Withdrawal failed");

        emit Withdrawn(controller, amount);
    }
}
