<template lang="html">
  <form @submit.prevent="signUpEntreprise">
    <card
      title="Signup an entreprise"
    >
      <input
        type="text"
        class="input-username"
        v-model="entrepriseName"
        placeholder="Name"
      />
      <span class="input-username">Members</span>
      <div
        v-for="user in users"
        v-bind:key="user.address"
        class="input-username"
      >
        <input
          type="checkbox"
          :id="user.address"
          :value="user.address"
          v-model="members"
        />
        <span>{{ user.account.username }}</span>
      </div>
      <input
        type="number"
        class="input-username"
        v-model="balance"
        placeholder="Balance"
      />
      <button type="submit" class="button-link"/>
    </card>
  </form>
</template>

<script lang="ts">
import { defineComponent, computed } from 'vue'
import { useStore } from 'vuex'
import Card from '@/components/Card.vue'

export default defineComponent({
  name: 'EntrepriseAccount',
  components: { Card },
  setup() {
    const store = useStore()
    const address = computed(() => store.state.account.address)
    const contract = computed(() => store.state.contract)
    return { address, contract }
  },
  data() {
    const users: any[] = []
    const entrepriseAccount = null
    const entrepriseName = ''
    const balance = ''
    const members: never[] = []
    return {
      users,
      entrepriseAccount,
      entrepriseName,
      balance,
      members,
    }
  },
  methods: {
    async signUpEntreprise() {
      const { contract, entrepriseName, members, balance } = this
      const name = entrepriseName.trim().replace(/ /g, '_')
      await contract.methods.signUpEntreprise(name, members, balance).send()
      this.entrepriseAccount = await contract.methods
        .entreprise(this.address)
        .call()
      await this.$router.push({ name: 'Account' })
    },
  },
  async mounted() {
    const { address, contract } = this
    this.entrepriseAccount = await contract.methods.entreprise(address).call()
    for (const address of await contract.methods.allUsers().call()) {
      const account = await contract.methods.user(address).call()
      this.users.push({ address: address, account: account })
    }
  },
})
</script>

<style lang="css" scoped>
.input-username {
  background: transparent;
  border: none;
  padding: 12px;
  outline: none;
  width: 100%;
  color: white;
  font-family: inherit;
  font-size: 1.3rem;
}

.button-link {
  display: inline;
  appearance: none;
  border: none;
  background: none;
  color: inherit;
  text-decoration: underline;
  font-family: inherit;
  font-size: inherit;
  font-weight: inherit;
  padding: 0;
  margin: 0;
  cursor: pointer;
}
</style>