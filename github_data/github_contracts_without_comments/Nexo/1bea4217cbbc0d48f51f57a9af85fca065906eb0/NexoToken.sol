pragma solidity 0.4.21;





import ;




contract nexotoken is token {

	
	string constant public name = ;
	string constant public symbol = ;
	uint8  constant public decimals = 18;


	
	


	

	
	

	address public investorsallocation = address(0xffffffffffffffffffffffffffffffffffffffff);
	uint256 public investorstotal = 525000000e18;


	

	
	
	
	

	address public overdraftallocation = address(0x1111111111111111111111111111111111111111);
	uint256 public overdrafttotal = 250000000e18;
	uint256 public overdraftperiodamount = 41666666e18;
	uint256 public overdraftunvested = 4e18;
	uint256 public overdraftcliff = 5 * 30 days;
	uint256 public overdraftperiodlength = 30 days;
	uint8   public overdraftperiodsnumber = 6;


	

	
	
	

	address public teamallocation  = address(0x2222222222222222222222222222222222222222);
	uint256 public teamtotal = 112500000e18;
	uint256 public teamperiodamount = 7031250e18;
	uint256 public teamunvested = 0;
	uint256 public teamcliff = 0;
	uint256 public teamperiodlength = 3 * 30 days;
	uint8   public teamperiodsnumber = 16;



	

	
	
	
	


	address public communityallocation  = address(0x3333333333333333333333333333333333333333);
	uint256 public communitytotal = 60000000e18;
	uint256 public communityperiodamount = 8333333e18;
	uint256 public communityunvested = 10000002e18;
	uint256 public communitycliff = 0;
	uint256 public communityperiodlength = 3 * 30 days;
	uint8   public communityperiodsnumber = 6;



	

	
	
	
	

	address public advisersallocation  = address(0x4444444444444444444444444444444444444444);
	uint256 public adviserstotal = 52500000e18;
	uint256 public advisersperiodamount = 2291666e18;
	uint256 public advisersunvested = 25000008e18;
	uint256 public adviserscliff = 0;
	uint256 public advisersperiodlength = 30 days;
	uint8   public advisersperiodsnumber = 12;


	

	function nexotoken() public {
		
		totalsupply = 1000000000e18;

		balances[investorsallocation] = investorstotal;
		balances[overdraftallocation] = overdrafttotal;
		balances[teamallocation] = teamtotal;
		balances[communityallocation] = communitytotal;
		balances[advisersallocation] = adviserstotal;

		
		allowed[investorsallocation][msg.sender] = investorstotal;
		allowed[overdraftallocation][msg.sender] = overdraftunvested;
		allowed[communityallocation][msg.sender] = communityunvested;
		allowed[advisersallocation][msg.sender] = advisersunvested;
	}

	

	function distributeinvestorstokens(address _to, uint256 _amountwithdecimals)
		public
		onlyowner
	{
		require(transferfrom(investorsallocation, _to, _amountwithdecimals));
	}

	

	function withdrawoverdrafttokens(address _to, uint256 _amountwithdecimals)
		public
		onlyowner
	{
		allowed[overdraftallocation][msg.sender] = allowance(overdraftallocation, msg.sender);
		require(transferfrom(overdraftallocation, _to, _amountwithdecimals));
	}

	function withdrawteamtokens(address _to, uint256 _amountwithdecimals)
		public
		onlyowner 
	{
		allowed[teamallocation][msg.sender] = allowance(teamallocation, msg.sender);
		require(transferfrom(teamallocation, _to, _amountwithdecimals));
	}

	function withdrawcommunitytokens(address _to, uint256 _amountwithdecimals)
		public
		onlyowner 
	{
		allowed[communityallocation][msg.sender] = allowance(communityallocation, msg.sender);
		require(transferfrom(communityallocation, _to, _amountwithdecimals));
	}

	function withdrawadviserstokens(address _to, uint256 _amountwithdecimals)
		public
		onlyowner 
	{
		allowed[advisersallocation][msg.sender] = allowance(advisersallocation, msg.sender);
		require(transferfrom(advisersallocation, _to, _amountwithdecimals));
	}

	
	function allowance(address _owner, address _spender)
		public
		view
		returns (uint256 remaining)
	{   
		if (_spender != owner) {
			return allowed[_owner][_spender];
		}

		uint256 unlockedtokens;
		uint256 spenttokens;

		if (_owner == overdraftallocation) {
			unlockedtokens = _calculateunlockedtokens(
				overdraftcliff,
				overdraftperiodlength,
				overdraftperiodamount,
				overdraftperiodsnumber,
				overdraftunvested
			);
			spenttokens = sub(overdrafttotal, balanceof(overdraftallocation));
		} else if (_owner == teamallocation) {
			unlockedtokens = _calculateunlockedtokens(
				teamcliff,
				teamperiodlength,
				teamperiodamount,
				teamperiodsnumber,
				teamunvested
			);
			spenttokens = sub(teamtotal, balanceof(teamallocation));
		} else if (_owner == communityallocation) {
			unlockedtokens = _calculateunlockedtokens(
				communitycliff,
				communityperiodlength,
				communityperiodamount,
				communityperiodsnumber,
				communityunvested
			);
			spenttokens = sub(communitytotal, balanceof(communityallocation));
		} else if (_owner == advisersallocation) {
			unlockedtokens = _calculateunlockedtokens(
				adviserscliff,
				advisersperiodlength,
				advisersperiodamount,
				advisersperiodsnumber,
				advisersunvested
			);
			spenttokens = sub(adviserstotal, balanceof(advisersallocation));
		} else {
			return allowed[_owner][_spender];
		}

		return sub(unlockedtokens, spenttokens);
	}

	
	function confirmownership()
		public
		onlypotentialowner
	{   
		
		allowed[investorsallocation][owner] = 0;

		
		allowed[investorsallocation][msg.sender] = balanceof(investorsallocation);

		
		allowed[overdraftallocation][owner] = 0;
		allowed[teamallocation][owner] = 0;
		allowed[communityallocation][owner] = 0;
		allowed[advisersallocation][owner] = 0;

		super.confirmownership();
	}

	function _calculateunlockedtokens(
		uint256 _cliff,
		uint256 _periodlength,
		uint256 _periodamount,
		uint8 _periodsnumber,
		uint256 _unvestedamount
	)
		private
		view
		returns (uint256) 
	{
		
		if (now < add(creationtime, _cliff)) {
			return _unvestedamount;
		}
		
		uint256 periods = div(sub(now, add(creationtime, _cliff)), _periodlength);
		periods = periods > _periodsnumber ? _periodsnumber : periods;
		return add(_unvestedamount, mul(periods, _periodamount));
	}
}
