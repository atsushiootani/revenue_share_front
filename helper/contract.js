import web3 from '../helper/web3';
import abi from '../helper/abi';

const address = "0x20Edd3b4350c1B5Af4f99DCa29AEf4c5C0473f1E";//"0x2Ad3064c7dbC4bEd6b52358C716AA8315bd681b3";//
const contract = web3.eth.Contract(abi, address);

export default contract;
