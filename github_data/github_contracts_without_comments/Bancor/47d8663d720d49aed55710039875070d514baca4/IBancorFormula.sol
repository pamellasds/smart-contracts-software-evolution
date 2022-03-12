pragma solidity 0.4.26;


contract ibancorformula {
    function purchaserate(uint256 _supply,
                          uint256 _reservebalance,
                          uint32 _reserveweight,
                          uint256 _amount)
                          public view returns (uint256);

    function salerate(uint256 _supply,
                      uint256 _reservebalance,
                      uint32 _reserveweight,
                      uint256 _amount)
                      public view returns (uint256);

    function crossreserverate(uint256 _sourcereservebalance,
                              uint32 _sourcereserveweight,
                              uint256 _targetreservebalance,
                              uint32 _targetreserveweight,
                              uint256 _amount)
                              public view returns (uint256);

    function fundcost(uint256 _supply,
                      uint256 _reservebalance,
                      uint32 _reserveratio,
                      uint256 _amount)
                      public view returns (uint256);

    function liquidaterate(uint256 _supply,
                           uint256 _reservebalance,
                           uint32 _reserveratio,
                           uint256 _amount)
                           public view returns (uint256);
}
