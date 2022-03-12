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
        return executor(uint160(bytes6()));
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

    authority constant authority = authority(uint160(bytes9()));

    
    function executor() internal view returns(address) {
        return authority.executor();
    }

    
    function add(address _signer, address _endorsor, bytes32 _identity) internal {
        return authority.add(_signer, _endorsor, _identity);
    }

    
    function revoke(address _signer) internal {
        return authority.revoke(_signer);
    }

    
    function get(address _signer) internal view returns(bool listed, address endorsor, bytes32 identity, bool active) {
        return authority.get(_signer);
    }

    
    function first() internal view returns(address) {
        return authority.first();
    }

    
    function next(address _signer) internal view returns(address) {
        return authority.next(_signer);
    }

    executor constant executor = executor(uint160(bytes6()));

    function propose(address _target, bytes _data) internal returns(bytes32) {
        return executor.propose(_target, _data);
    }

    function approve(bytes32 _proposalid) internal {
        return executor.approve(_proposalid);
    }

    function execute(bytes32 _proposalid) internal {
        return executor.execute(_proposalid);
    }

    function addapprover(address _approver, bytes32 _identity) internal {
        return executor.addapprover(_approver, _identity);
    }

    function revokeapprover(address _approver) internal {
        return executor.revokeapprover(_approver);
    }

    function attachvotingcontract(address _contract) internal {
        return executor.attachvotingcontract(_contract);
    }

    function detachvotingcontract(address _contract) internal {
        return executor.detachvotingcontract(_contract);
    }

    extension constant extension = extension(uint160(bytes9()));

    
    function blake2b256(bytes _value) internal view returns(bytes32) {
        return extension.blake2b256(_value);
    }

    
    function blockid(uint num) internal view returns(bytes32) {
        return extension.blockid(num);
    }
 
    function blocktotalscore(uint num) internal view returns(uint64) {
        return extension.blocktotalscore(num);
    }

    function blocktime(uint num) internal view returns(uint) {
        return extension.blocktime(num);
    }

    function blocksigner(uint num) internal view returns(address) {
        return extension.blocksigner(num);
    }

    
    function totalsupply() internal view returns(uint256) {
        return extension.totalsupply();
    }

    
    function txprovedwork() internal view returns(uint256) {
        return extension.txprovedwork();
    }
    function txid() internal view returns(bytes32) {
        return extension.txid();
    }
    function txblockref() internal view returns(bytes8) {
        return extension.txblockref();
    }

    function txexpiration() internal view returns(uint) {
        return extension.txexpiration();
    }

    params constant params = params(uint160(bytes6()));
    function executor() internal view returns(address) {
        return params.executor();
    }
 
    function set(bytes32 _key, uint256 _value) internal {
        return params.set(_key, _value);
    }

    function get(bytes32 _key) internal view returns(uint256) {
        return params.get(_key);
    }
}
