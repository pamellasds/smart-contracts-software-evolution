pragma solidity ^0.4.23;

import ;
import ;
import ;
import ;
import ;
import ;


library builtin {

    
    function getauthority() internal pure returns(authority) {
        return authority(uint160(bytes9()));
    }

    
    function getenergy() internal pure returns(energy) {
        return energy(uint160(bytes6()));
    }

    
    function getextension() internal pure returns(extension) {
        return extension(uint160(bytes9()));
    }

    
    function getparams() internal pure returns(params) {
        return params(uint160(bytes6()));
    }

    
    function getexecutor() internal pure returns(executor) {
        return executor(uint160(bytes8()));
    }


    energy constant energy = energy(uint160(bytes6()));

    
    function $energy(address self) internal view returns(uint256 amount){
        return energy.balanceof(self);
    }

    
    function $transferenergy(address self, uint256 amount) internal{
        energy.transfer(self, amount);
    }

    
    function $moveenergyto(address self, address to, uint256 amount) internal{
        energy.move(self, to, amount);
    }

    prototype constant prototype = prototype(uint160(bytes9()));

    
    function $master(address self) internal view returns(address){
        return prototype.master(self);
    }

    
    function $setmaster(address self, address newmaster) internal {
        prototype.setmaster(self, newmaster);
    }

    
    function $balance(address self, uint blocknumber) internal view returns(uint256){
        return prototype.balance(self, blocknumber);
    }

    
    function $energy(address self, uint blocknumber) internal view returns(uint256){
        return prototype.energy(self, blocknumber);
    }

    
    function $hascode(address self) internal view returns(bool){
        return prototype.hascode(self);
    }

    
    function $storagefor(address self, bytes32 key) internal view returns(bytes32){
        return prototype.storagefor(self, key);
    }

    
    function $creditplan(address self) internal view returns(uint256 credit, uint256 recoveryrate){
        return prototype.creditplan(self);
    }

    
    function $setcreditplan(address self, uint256 credit, uint256 recoveryrate) internal{
        prototype.setcreditplan(self, credit, recoveryrate);
    }

    
    function $isuser(address self, address user) internal view returns(bool){
        return prototype.isuser(self, user);
    }

    
    function $usercredit(address self, address user) internal view returns(uint256){
        return prototype.usercredit(self, user);
    }

    
    function $adduser(address self, address user) internal{
        prototype.adduser(self, user);
    }

    
    function $removeuser(address self, address user) internal{
        prototype.removeuser(self, user);
    }

    
    function $sponsor(address self) internal{
        prototype.sponsor(self);
    }

    
    function $unsponsor(address self) internal {
        prototype.unsponsor(self);
    }

    
    function $issponsor(address self, address sponsor) internal view returns(bool){
        return prototype.issponsor(self, sponsor);
    }

    
    function $selectsponsor(address self, address sponsor) internal{
        prototype.selectsponsor(self, sponsor);
    }

    
    function $currentsponsor(address self) internal view returns(address){
        return prototype.currentsponsor(self);
    }
}
