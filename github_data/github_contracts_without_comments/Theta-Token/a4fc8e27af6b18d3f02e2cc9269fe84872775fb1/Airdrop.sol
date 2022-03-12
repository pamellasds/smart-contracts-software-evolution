pragma solidity ^0.4.18;

import ;





contract airdrop {

	uint8 public constant decimals = 18;

	thetatoken token;

	function airdrop(address _token) public {
		require(_token != 0x0);
		token = thetatoken(_token);
	}

    function dropinbatch(address _source, address[] _recipients, uint _amountinwei) public {
    	for (uint i = 0; i < _recipients.length; i ++) {
            address recipient = _recipients[i];
            token.transferfrom(_source, recipient, _amountinwei);
        }
    }

}

