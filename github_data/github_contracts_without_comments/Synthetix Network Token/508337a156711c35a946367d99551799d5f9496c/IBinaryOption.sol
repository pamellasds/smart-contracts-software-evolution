pragma solidity >=0.4.24;

import ;
import ;

interface ibinaryoption {
    

    function market() external view returns (ibinaryoptionmarket);

    function bidof(address account) external view returns (uint);
    function totalbids() external view returns (uint);

    function balanceof(address account) external view returns (uint);
    function totalsupply() external view returns (uint);

    function claimablebalanceof(address account) external view returns (uint);
    function totalclaimablesupply() external view returns (uint);
}
