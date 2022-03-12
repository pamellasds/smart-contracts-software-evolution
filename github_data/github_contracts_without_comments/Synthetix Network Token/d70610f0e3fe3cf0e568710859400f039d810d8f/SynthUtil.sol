pragma solidity ^0.5.16;


import ;
import ;
import ;
import ;
import ;


contract synthutil {
    iaddressresolver public addressresolverproxy;

    bytes32 internal constant contract_synthetix = ;
    bytes32 internal constant contract_exrates = ;
    bytes32 internal constant susd = ;

    constructor(address resolver) public {
        addressresolverproxy = iaddressresolver(resolver);
    }

    function _synthetix() internal view returns (isynthetix) {
        return isynthetix(addressresolverproxy.requireandgetaddress(contract_synthetix, ));
    }

    function _exchangerates() internal view returns (iexchangerates) {
        return iexchangerates(addressresolverproxy.requireandgetaddress(contract_exrates, ));
    }

    function totalsynthsinkey(address account, bytes32 currencykey) external view returns (uint total) {
        isynthetix synthetix = _synthetix();
        iexchangerates exchangerates = _exchangerates();
        uint numsynths = synthetix.availablesynthcount();
        for (uint i = 0; i < numsynths; i++) {
            isynth synth = synthetix.availablesynths(i);
            total += exchangerates.effectivevalue(
                synth.currencykey(),
                ierc20(address(synth)).balanceof(account),
                currencykey
            );
        }
        return total;
    }

    function synthsbalances(address account)
        external
        view
        returns (
            bytes32[] memory,
            uint[] memory,
            uint[] memory
        )
    {
        isynthetix synthetix = _synthetix();
        iexchangerates exchangerates = _exchangerates();
        uint numsynths = synthetix.availablesynthcount();
        bytes32[] memory currencykeys = new bytes32[](numsynths);
        uint[] memory balances = new uint[](numsynths);
        uint[] memory susdbalances = new uint[](numsynths);
        for (uint i = 0; i < numsynths; i++) {
            isynth synth = synthetix.availablesynths(i);
            currencykeys[i] = synth.currencykey();
            balances[i] = ierc20(address(synth)).balanceof(account);
            susdbalances[i] = exchangerates.effectivevalue(currencykeys[i], balances[i], susd);
        }
        return (currencykeys, balances, susdbalances);
    }

    function frozensynths() external view returns (bytes32[] memory) {
        isynthetix synthetix = _synthetix();
        iexchangerates exchangerates = _exchangerates();
        uint numsynths = synthetix.availablesynthcount();
        bytes32[] memory frozensynthskeys = new bytes32[](numsynths);
        for (uint i = 0; i < numsynths; i++) {
            isynth synth = synthetix.availablesynths(i);
            if (exchangerates.rateisfrozen(synth.currencykey())) {
                frozensynthskeys[i] = synth.currencykey();
            }
        }
        return frozensynthskeys;
    }

    function synthsrates() external view returns (bytes32[] memory, uint[] memory) {
        bytes32[] memory currencykeys = _synthetix().availablecurrencykeys();
        return (currencykeys, _exchangerates().ratesforcurrencies(currencykeys));
    }

    function synthstotalsupplies()
        external
        view
        returns (
            bytes32[] memory,
            uint256[] memory,
            uint256[] memory
        )
    {
        isynthetix synthetix = _synthetix();
        iexchangerates exchangerates = _exchangerates();

        uint256 numsynths = synthetix.availablesynthcount();
        bytes32[] memory currencykeys = new bytes32[](numsynths);
        uint256[] memory balances = new uint256[](numsynths);
        uint256[] memory susdbalances = new uint256[](numsynths);
        for (uint256 i = 0; i < numsynths; i++) {
            isynth synth = synthetix.availablesynths(i);
            currencykeys[i] = synth.currencykey();
            balances[i] = ierc20(address(synth)).totalsupply();
            susdbalances[i] = exchangerates.effectivevalue(currencykeys[i], balances[i], susd);
        }
        return (currencykeys, balances, susdbalances);
    }
}
