pragma solidity ^0.5.16;


interface iissuer {
    
    function canburnsynths(address account) external view returns (bool);

    function lastissueevent(address account) external view returns (uint);

    
    function issuesynths(address from, uint amount) external;

    function issuesynthsonbehalf(
        address issuefor,
        address from,
        uint amount
    ) external;

    function issuemaxsynths(address from) external;

    function issuemaxsynthsonbehalf(address issuefor, address from) external;

    function burnsynths(address from, uint amount) external;

    function burnsynthsonbehalf(
        address burnforaddress,
        address from,
        uint amount
    ) external;

    function burnsynthstotarget(address from) external;

    function burnsynthstotargetonbehalf(address burnforaddress, address from) external;
}
