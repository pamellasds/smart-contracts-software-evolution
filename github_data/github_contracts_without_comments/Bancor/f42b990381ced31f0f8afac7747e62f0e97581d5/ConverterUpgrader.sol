
pragma solidity 0.6.12;
import ;
import ;
import ;
import ;
import ;
import ;
import ;


contract converterupgrader is iconverterupgrader, contractregistryclient {
    ierc20token private constant eth_reserve_address = ierc20token(0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
    iethertoken public ethertoken;

    
    event converterowned(iconverter indexed _converter, address indexed _owner);

    
    event converterupgrade(address indexed _oldconverter, address indexed _newconverter);

    
    constructor(icontractregistry _registry, iethertoken _ethertoken) contractregistryclient(_registry) public {
        ethertoken = _ethertoken;
    }

    
    function upgrade(bytes32 _version) public override {
        upgradeold(iconverter(msg.sender), _version);
    }

    
    function upgrade(uint16 _version) public override {
        upgradeold(iconverter(msg.sender), bytes32(uint256(_version)));
    }

    
    function upgradeold(iconverter _converter, bytes32 _version) public {
        _version;
        iconverter converter = iconverter(_converter);
        address prevowner = converter.owner();
        acceptconverterownership(converter);
        iconverter newconverter = createconverter(converter);
        copyreserves(converter, newconverter);
        copyconversionfee(converter, newconverter);
        transferreservebalances(converter, newconverter);
        iconverteranchor anchor = converter.token();

        
        bool activate = isv28orhigherconverter(converter) && converter.isactive();

        if (anchor.owner() == address(converter)) {
            converter.transfertokenownership(address(newconverter));
            newconverter.acceptanchorownership();
        }

        handletypespecificdata(converter, newconverter, activate);

        converter.transferownership(prevowner);
        newconverter.transferownership(prevowner);

        emit converterupgrade(address(converter), address(newconverter));
    }

    
    function acceptconverterownership(iconverter _oldconverter) private {
        _oldconverter.acceptownership();
        emit converterowned(_oldconverter, address(this));
    }

    
    function createconverter(iconverter _oldconverter) private returns (iconverter) {
        iconverteranchor anchor = _oldconverter.token();
        uint32 maxconversionfee = _oldconverter.maxconversionfee();
        uint16 reservetokencount = _oldconverter.connectortokencount();

        
        uint16 newtype = 0;
        
        if (isv28orhigherconverter(_oldconverter))
            newtype = _oldconverter.convertertype();
        
        else if (reservetokencount > 1)
            newtype = 1;

        iconverterfactory converterfactory = iconverterfactory(addressof(converter_factory));
        iconverter converter = converterfactory.createconverter(newtype, anchor, registry, maxconversionfee);

        converter.acceptownership();
        return converter;
    }

    
    function copyreserves(iconverter _oldconverter, iconverter _newconverter) private {
        uint16 reservetokencount = _oldconverter.connectortokencount();

        for (uint16 i = 0; i < reservetokencount; i++) {
            ierc20token reserveaddress = _oldconverter.connectortokens(i);
            (, uint32 weight, , , ) = _oldconverter.connectors(reserveaddress);

            
            if (reserveaddress == eth_reserve_address) {
                _newconverter.addreserve(eth_reserve_address, weight);
            }
            
            else if (reserveaddress == ethertoken) {
                _newconverter.addreserve(eth_reserve_address, weight);
            }
            
            else {
                _newconverter.addreserve(reserveaddress, weight);
            }
        }
    }

    
    function copyconversionfee(iconverter _oldconverter, iconverter _newconverter) private {
        uint32 conversionfee = _oldconverter.conversionfee();
        _newconverter.setconversionfee(conversionfee);
    }

    
    function transferreservebalances(iconverter _oldconverter, iconverter _newconverter) private {
        uint256 reservebalance;
        uint16 reservetokencount = _oldconverter.connectortokencount();

        for (uint16 i = 0; i < reservetokencount; i++) {
            ierc20token reserveaddress = _oldconverter.connectortokens(i);
            
            if (reserveaddress == eth_reserve_address) {
                _oldconverter.withdraweth(address(_newconverter));
            }
            
            else if (reserveaddress == ethertoken) {
                reservebalance = ethertoken.balanceof(address(_oldconverter));
                _oldconverter.withdrawtokens(ethertoken, address(this), reservebalance);
                ethertoken.withdrawto(address(_newconverter), reservebalance);
            }
            
            else {
                ierc20token connector = reserveaddress;
                reservebalance = connector.balanceof(address(_oldconverter));
                _oldconverter.withdrawtokens(connector, address(_newconverter), reservebalance);
            }
        }
    }

    
    function handletypespecificdata(iconverter _oldconverter, iconverter _newconverter, bool _activate) private {
        if (!isv28orhigherconverter(_oldconverter))
            return;

        uint16 convertertype = _oldconverter.convertertype();
        if (convertertype == 2) {
            iliquiditypoolv2converter oldconverter = iliquiditypoolv2converter(address(_oldconverter));
            iliquiditypoolv2converter newconverter = iliquiditypoolv2converter(address(_newconverter));

            uint16 reservetokencount = oldconverter.connectortokencount();
            for (uint16 i = 0; i < reservetokencount; i++) {
                
                ierc20token reservetokenaddress = oldconverter.connectortokens(i);
                uint256 balance = oldconverter.reservestakedbalance(reservetokenaddress);
                newconverter.setreservestakedbalance(reservetokenaddress, balance);
            }

            if (!_activate) {
                return;
            }

            
            ierc20token primaryreservetoken = oldconverter.primaryreservetoken();

            
            ipriceoracle priceoracle = oldconverter.priceoracle();
            ichainlinkpriceoracle oraclea = priceoracle.tokenaoracle();
            ichainlinkpriceoracle oracleb = priceoracle.tokenboracle();

            
            newconverter.activate(primaryreservetoken, oraclea, oracleb);
        }
    }

    bytes4 private constant is_v28_or_higher_func_selector = bytes4(keccak256());

    
    
    function isv28orhigherconverter(iconverter _converter) internal view returns (bool) {
        bytes memory data = abi.encodewithselector(is_v28_or_higher_func_selector);
        (bool success, bytes memory returndata) = address(_converter).staticcall{ gas: 4000 }(data);

        if (success && returndata.length == 32) {
            return abi.decode(returndata, (bool));
        }

        return false;
    }
}
