pragma solidity ^0.4.18;



contract token {
    
    function balanceof(address _owner) public constant returns (uint balance);
    
    function transfer(address _to, uint _value) public returns (bool success);
}


contract airdrop {

	token token;

	address public admin = 0x0;

	function airdrop(address _token, address _admin) public {
		require(_token != 0x0);
		require(_admin != 0x0);
		token = token(_token);
		admin = _admin;
	}

    function dropinbatch(address[] _recipients, uint _tokenamountinwei) only(admin) public {
    	for (uint i = 0; i < _recipients.length; i ++) {
            address recipient = _recipients[i];
            token.transfer(recipient, _tokenamountinwei);
        }
    }

    function withdrawether(address withdrawaddress, uint _etheramountinwei) only(admin) public {
    	withdrawaddress.transfer(_etheramountinwei);
    }

    modifier only(address x) {
        require(msg.sender == x);
        _;
    }

}

