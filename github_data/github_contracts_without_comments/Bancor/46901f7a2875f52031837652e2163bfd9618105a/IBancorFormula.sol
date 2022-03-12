
pragma solidity 0.6.12;


interface ibancorformula {
    function purchasetargetamount(uint256 _supply,
                                  uint256 _reservebalance,
                                  uint32 _reserveweight,
                                  uint256 _amount)
                                  external view returns (uint256);

    function saletargetamount(uint256 _supply,
                              uint256 _reservebalance,
                              uint32 _reserveweight,
                              uint256 _amount)
                              external view returns (uint256);

    function crossreservetargetamount(uint256 _sourcereservebalance,
                                      uint32 _sourcereserveweight,
                                      uint256 _targetreservebalance,
                                      uint32 _targetreserveweight,
                                      uint256 _amount)
                                      external view returns (uint256);

    function fundcost(uint256 _supply,
                      uint256 _reservebalance,
                      uint32 _reserveratio,
                      uint256 _amount)
                      external view returns (uint256);

    function fundsupplyamount(uint256 _supply,
                              uint256 _reservebalance,
                              uint32 _reserveratio,
                              uint256 _amount)
                              external view returns (uint256);

    function liquidatereserveamount(uint256 _supply,
                                    uint256 _reservebalance,
                                    uint32 _reserveratio,
                                    uint256 _amount)
                                    external view returns (uint256);

    function balancedweights(uint256 _primaryreservestakedbalance,
                             uint256 _primaryreservebalance,
                             uint256 _secondaryreservebalance,
                             uint256 _reserveratenumerator,
                             uint256 _reserveratedenominator)
                             external view returns (uint32, uint32);
}
