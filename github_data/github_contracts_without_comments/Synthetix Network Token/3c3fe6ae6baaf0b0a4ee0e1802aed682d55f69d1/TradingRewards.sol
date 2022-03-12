pragma solidity ^0.5.16;


import ;
import ;
import ;


import ;
import ;
import ;


import ;


import ;
import ;


contract tradingrewards is itradingrewards, reentrancyguard, owned, pausable, mixinresolver {
    using safemath for uint;
    using safedecimalmath for uint;
    using safeerc20 for ierc20;

    

    uint private _currentperiodid;
    uint private _balanceassignedtorewards;
    mapping(uint => period) private _periods;

    struct period {
        bool isfinalized;
        uint recordedfees;
        uint totalrewards;
        uint availablerewards;
        mapping(address => uint) unaccountedfeesforaccount;
    }

    address private _periodcontroller;

    

    bytes32 private constant contract_exchanger = ;
    bytes32 private constant contract_synthetix = ;

    bytes32[24] private _addressestocache = [contract_exchanger, contract_synthetix];

    

    constructor(
        address owner,
        address periodcontroller,
        address resolver
    ) public owned(owner) mixinresolver(resolver, _addressestocache) {
        require(periodcontroller != address(0), );

        _periodcontroller = periodcontroller;
    }

    

    function synthetix() internal view returns (ierc20) {
        return ierc20(requireandgetaddress(contract_synthetix, ));
    }

    function exchanger() internal view returns (iexchanger) {
        return iexchanger(requireandgetaddress(contract_exchanger, ));
    }

    function getavailablerewards() external view returns (uint) {
        return _balanceassignedtorewards;
    }

    function getunassignedrewards() external view returns (uint) {
        return synthetix().balanceof(address(this)).sub(_balanceassignedtorewards);
    }

    function getrewardstoken() external view returns (address) {
        return address(synthetix());
    }

    function getperiodcontroller() external view returns (address) {
        return _periodcontroller;
    }

    function getcurrentperiod() external view returns (uint) {
        return _currentperiodid;
    }

    function getperiodisclaimable(uint periodid) external view returns (bool) {
        return _periods[periodid].isfinalized;
    }

    function getperiodisfinalized(uint periodid) external view returns (bool) {
        return _periods[periodid].isfinalized;
    }

    function getperiodrecordedfees(uint periodid) external view returns (uint) {
        return _periods[periodid].recordedfees;
    }

    function getperiodtotalrewards(uint periodid) external view returns (uint) {
        return _periods[periodid].totalrewards;
    }

    function getperiodavailablerewards(uint periodid) external view returns (uint) {
        return _periods[periodid].availablerewards;
    }

    function getunaccountedfeesforaccountforperiod(address account, uint periodid) external view returns (uint) {
        return _periods[periodid].unaccountedfeesforaccount[account];
    }

    function getavailablerewardsforaccountforperiod(address account, uint periodid) external view returns (uint) {
        return _calculaterewards(account, periodid);
    }

    function getavailablerewardsforaccountforperiods(address account, uint[] calldata periodids)
        external
        view
        returns (uint totalrewards)
    {
        for (uint i = 0; i < periodids.length; i++) {
            uint periodid = periodids[i];

            totalrewards = totalrewards.add(_calculaterewards(account, periodid));
        }
    }

    function _calculaterewards(address account, uint periodid) internal view returns (uint) {
        period storage period = _periods[periodid];
        if (period.availablerewards == 0 || period.recordedfees == 0 || !period.isfinalized) {
            return 0;
        }

        uint accountfees = period.unaccountedfeesforaccount[account];
        if (accountfees == 0) {
            return 0;
        }

        uint participationratio = accountfees.dividedecimal(period.recordedfees);
        return participationratio.multiplydecimal(period.totalrewards);
    }

    

    function claimrewardsforperiod(uint periodid) external nonreentrant notpaused {
        _claimrewards(msg.sender, periodid);
    }

    function claimrewardsforperiods(uint[] calldata periodids) external nonreentrant notpaused {
        for (uint i = 0; i < periodids.length; i++) {
            uint periodid = periodids[i];

            
            _claimrewards(msg.sender, periodid);
        }
    }

    function _claimrewards(address account, uint periodid) internal {
        period storage period = _periods[periodid];
        require(period.isfinalized, );

        uint amounttoclaim = _calculaterewards(account, periodid);
        require(amounttoclaim > 0, );

        period.unaccountedfeesforaccount[account] = 0;
        period.availablerewards = period.availablerewards.sub(amounttoclaim);

        _balanceassignedtorewards = _balanceassignedtorewards.sub(amounttoclaim);

        synthetix().safetransfer(account, amounttoclaim);

        emit rewardsclaimed(account, amounttoclaim, periodid);
    }

    

    function recordexchangefeeforaccount(uint usdfeeamount, address account) external onlyexchanger {
        period storage period = _periods[_currentperiodid];
        
        

        period.unaccountedfeesforaccount[account] = period.unaccountedfeesforaccount[account].add(usdfeeamount);
        period.recordedfees = period.recordedfees.add(usdfeeamount);

        emit exchangefeerecorded(account, usdfeeamount, _currentperiodid);
    }

    function closecurrentperiodwithrewards(uint rewards) external onlyperiodcontroller {
        uint currentbalance = synthetix().balanceof(address(this));
        uint availablefornewrewards = currentbalance.sub(_balanceassignedtorewards);
        require(rewards <= availablefornewrewards, );

        period storage period = _periods[_currentperiodid];

        period.totalrewards = rewards;
        period.availablerewards = rewards;
        period.isfinalized = true;

        _balanceassignedtorewards = _balanceassignedtorewards.add(rewards);

        emit periodfinalizedwithrewards(_currentperiodid, rewards);

        _currentperiodid = _currentperiodid.add(1);

        emit newperiodstarted(_currentperiodid);
    }

    
    function recoverether(address payable recoveraddress) external onlyowner {
        _validaterecoveraddress(recoveraddress);

        uint amount = address(this).balance;
        recoveraddress.transfer(amount);

        emit etherrecovered(recoveraddress, amount);
    }

    function recovertokens(address tokenaddress, address recoveraddress) external onlyowner {
        _validaterecoveraddress(recoveraddress);
        require(tokenaddress != address(synthetix()), );

        ierc20 token = ierc20(tokenaddress);

        uint tokenbalance = token.balanceof(address(this));
        require(tokenbalance > 0, );

        token.safetransfer(recoveraddress, tokenbalance);

        emit tokensrecovered(tokenaddress, recoveraddress, tokenbalance);
    }

    function recoverunassignedrewardtokens(address recoveraddress) external onlyowner {
        _validaterecoveraddress(recoveraddress);

        uint tokenbalance = synthetix().balanceof(address(this));
        require(tokenbalance > 0, );

        uint unassignedbalance = tokenbalance.sub(_balanceassignedtorewards);
        require(unassignedbalance > 0, );

        synthetix().safetransfer(recoveraddress, unassignedbalance);

        emit unassignedrewardtokensrecovered(recoveraddress, unassignedbalance);
    }

    function recoverassignedrewardtokensanddestroyperiod(address recoveraddress, uint periodid) external onlyowner {
        _validaterecoveraddress(recoveraddress);
        require(periodid < _currentperiodid, );

        period storage period = _periods[periodid];
        require(period.availablerewards > 0, );

        uint amount = period.availablerewards;
        synthetix().safetransfer(recoveraddress, amount);

        _balanceassignedtorewards = _balanceassignedtorewards.sub(amount);

        delete _periods[periodid];

        emit assignedrewardtokensrecovered(recoveraddress, amount, periodid);
    }

    function _validaterecoveraddress(address recoveraddress) internal view {
        if (recoveraddress == address(0) || recoveraddress == address(this)) {
            revert();
        }
    }

    function setperiodcontroller(address newperiodcontroller) external onlyowner {
        require(newperiodcontroller != address(0), );

        _periodcontroller = newperiodcontroller;

        emit periodcontrollerchanged(newperiodcontroller);
    }

    

    modifier onlyperiodcontroller() {
        require(msg.sender == _periodcontroller, );
        _;
    }

    modifier onlyexchanger() {
        require(msg.sender == address(exchanger()), );
        _;
    }

    

    event exchangefeerecorded(address indexed account, uint amount, uint periodid);
    event rewardsclaimed(address indexed account, uint amount, uint periodid);
    event newperiodstarted(uint periodid);
    event periodfinalizedwithrewards(uint periodid, uint rewards);
    event tokensrecovered(address tokenaddress, address recoveraddress, uint amount);
    event etherrecovered(address recoveraddress, uint amount);
    event unassignedrewardtokensrecovered(address recoveraddress, uint amount);
    event assignedrewardtokensrecovered(address recoveraddress, uint amount, uint periodid);
    event periodcontrollerchanged(address newperiodcontroller);
}
