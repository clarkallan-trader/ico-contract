pragma solidity ^0.4.6;

import "./StandardToken.sol";
import "./SafeMath.sol";

/// @title Token contract - Implements Standard Token Interface with HumaniQ features.
/// @author Evgeny Yurtaev - <evgeny@etherionlab.com>
contract HumaniqToken is StandardToken, SafeMath {

    /*
     * External contracts
     */
    address public minter;

    /*
     * Token meta data
     */
    string constant public name = "HumaniQ";
    string constant public symbol = "HMQ";
    uint8 constant public decimals = 8;

    address public founder;
    address public allocationAddress = 0x1111111111111111111111111111111111111111;

    uint public maxTotalSupply;

    /*
     * Modifiers
     */
    modifier onlyFounder() {
        // Only founder is allowed to do this action.
        if (msg.sender != founder) {
            throw;
        }
        _;
    }

    modifier isMinter() {
        // Only minter is allowed to proceed.
        if (msg.sender != minter) {
            throw;
        }
        _;
    }

    /*
     * Contract functions
     */

    /// @dev Crowdfunding contract issues new tokens for address. Returns success.
    /// @param _for Address of receiver.
    /// @param tokenCount Number of tokens to issue.
    function issueTokens(address _for, uint tokenCount)
        external
        payable
        isMinter
        returns (bool)
    {
        if (tokenCount == 0) {
            return false;
        }

        if (add(totalSupply, tokenCount) > maxTotalSupply) {
          throw;
        }

        totalSupply = add(totalSupply, tokenCount);
        balances[_for] = add(balances[_for], tokenCount);
        Issuance(_for, tokenCount);
        return true;
    }

    /// @dev Function to change address that is allowed to do emission.
    /// @param newAddress Address of new emission contract.
    function changeMinter(address newAddress)
        public
        onlyFounder
        returns (bool)
    {
        minter = newAddress;
    }

    /// @dev Contract constructor function sets initial token balances.
    /// @param _founder Address of the founder of HumaniQ.
    function HumaniqToken(address _founder)
    {
        founder = _founder;

        // Allocate all created tokens to allocationAddress.
        balances[allocationAddress] = 120000000 * 100000000;
        // Allow founder to distribute them.
        allowed[allocationAddress][minter] = 120000000 * 100000000;

        // Give 14 percent of all tokens to founders.
        balances[_founder] = div(mul(balances[allocationAddress], 14), 86);

        // Set correct totalSupply and limit maximum total supply.
        totalSupply = add(balances[allocationAddress], balances[_founder]);
        maxTotalSupply = mul(totalSupply, 5);
    }
}
