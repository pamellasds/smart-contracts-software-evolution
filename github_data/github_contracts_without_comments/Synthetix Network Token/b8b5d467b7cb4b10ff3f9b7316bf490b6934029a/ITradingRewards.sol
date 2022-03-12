pragma solidity >=0.4.24;


interface itradingrewards {
    

    function getavailablerewards() external view returns (uint);

    function getunassignedrewards() external view returns (uint);

    function getrewardstoken() external view returns (address);

    function getperiodcontroller() external view returns (address);

    function getcurrentperiod() external view returns (uint);

    function getperiodisclaimable(uint periodid) external view returns (bool);

    function getperiodisfinalized(uint periodid) external view returns (bool);

    function getperiodrecordedfees(uint periodid) external view returns (uint);

    function getperiodtotalrewards(uint periodid) external view returns (uint);

    function getperiodavailablerewards(uint periodid) external view returns (uint);

    function getunaccountedfeesforaccountforperiod(address account, uint periodid) external view returns (uint);

    function getavailablerewardsforaccountforperiod(address account, uint periodid) external view returns (uint);

    function getavailablerewardsforaccountforperiods(address account, uint[] calldata periodids)
        external
        view
        returns (uint totalrewards);

    

    function claimrewardsforperiod(uint periodid) external;

    function claimrewardsforperiods(uint[] calldata periodids) external;

    

    function recordexchangefeeforaccount(uint usdfeeamount, address account) external;

    function closecurrentperiodwithrewards(uint rewards) external;

    function recoverether(address payable recoveraddress) external;

    function recovertokens(address tokenaddress, address recoveraddress) external;

    function recoverunassignedrewardtokens(address recoveraddress) external;

    function recoverassignedrewardtokensanddestroyperiod(address recoveraddress, uint periodid) external;

    function setperiodcontroller(address newperiodcontroller) external;
}
