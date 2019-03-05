<template>
  <section class="container">
    <div>
      <h1 class="title">
        revenue share contract
      </h1>
      <h2 class="subtitle">
        報酬分配を自動化して、みんなのお金をクリアに！
      </h2>
      <br>
      <h2>あなたの情報</h2>
      <ul>
        <li>
          address: {{CoinBase}}
        </li>
        <li>
          <template v-if="IsMember">あなたはメンバーです</template>
          <template v-else>あなたはメンバーではありません</template>
        </li>
      </ul>
      <br>

      <div>
        情報取得
        <button type="button" class="btn btn-primary" @click="member_check">click here</button>
      </div>

      <div>
        プロジェクトに参加する
        <button type="button" class="btn btn-primary" @click="request_to_join">click here</button>
      </div>
      <div>
        このプロジェクトに送金する
        <input type="text" class="form-control" placeholder="ether" v-model="PayAmount">
        <button type="button" class="btn btn-primary" @click="pay_to_project">pay!</button>
      </div>
    </div>
  </section>
</template>

<script>
import AppLogo from '~/components/AppLogo.vue'
//import web3 from '../helper/web3';
//import contract from '../helper/contract';
import Web3 from 'web3';
import abi from '../helper/abi';

var web3;
var contractInstance;

export default {
  data() {
    return {
      Host: "wait..",
      CoinBase: "wait...",
      AccountCount: "0",
      Account0: "wait...",
      IsMember: false,
      Members: [],
      PayAmount: 1,
    }
  },
  beforeMount(){
    web3 = new Web3(ethereum);
    console.log('web3:', web3);
    ethereum.enable();

    let contractAddress = "0x20Edd3b4350c1B5Af4f99DCa29AEf4c5C0473f1E";
    let MyContract = web3.eth.contract(abi);
    contractInstance = MyContract.at(contractAddress);
    console.log("contractInstance:", contractInstance);
    console.log('contractInstance.transactionHash:', contractInstance.transactionHash); //null
    console.log('contractInstance.address:', contractInstance.address); //contractAddress
  },
  methods: {
    member_check(event){
      console.log("contract: ", contractInstance);
      contractInstance.amIMember((err, result)=>{
        if (err) { console.log(err); }
        else {
          console.log("amIMember: ", result);
        }
      });

      contractInstance.three((err, result) => {
        if (err) { console.log(err); }
        else {
          console.log("three:", result);
        }
      })
    },
    request_to_join(event){
      console.log("request_to_join: ", contractInstance);
      contractInstance.requestToJoin.sendTransaction({
        value: 0,
        gas: 200000,
        //from: "0xcfc6060C859FA123E3860d84868479A5e20F24a3",
      }, (err, transactionHash) =>{
        if (err) { console.log(err); }
        else {
          console.log("requestedToJoin: ", transactionHash);
        }
      });
    },
    pay_to_project(event){
      console.log("pay_to_project: ", contractInstance);
      web3.eth.sendTransaction({
        value: web3.utils.toWei(this.PayAmount, 'ether'),
        gas:                200000,
        from: "0x9c4E9Ac07D994F1Bf0b6CCADF015544449210C21"
      }, ((err, hash) => {
        if (err) { console.log(err); }
        else {
          console.log('txHash: ', hash); //"0xc00d7771c68ee0636beb7e36939f7fc2ec5715fdfd931f9dfd5a407295baf1c2"
        }
      }));
    }
  }
}


</script>

<style>
.container {
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  text-align: center;
}

.title {
  font-family: "Quicksand", "Source Sans Pro", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif; /* 1 */
  display: block;
  font-weight: 300;
  font-size: 100px;
  color: #35495e;
  letter-spacing: 1px;
}

.subtitle {
  font-weight: 300;
  font-size: 42px;
  color: #526488;
  word-spacing: 5px;
  padding-bottom: 15px;
}

.links {
  padding-top: 15px;
}
</style>

