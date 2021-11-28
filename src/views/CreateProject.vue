<template lang="html">
  <form @submit.prevent="createProject">
    <card
      title="Create a project"
    >
      <div v-if="entreprise">
        <span class="input-username">
          This project belongs to
        </span>
        <div class="input-username">
          <input
            type="radio"
            id="user"
            v-bind:value="true"
            v-model="belongsToUser"
          />
          <label for="user">User: {{ account.username }}</label>
        </div>
        <div class="input-username">
          <input
            type="radio"
            id="entreprise"
            v-bind:value="false"
            v-model="belongsToUser"
          />
          <label for="entreprise"
            >Entreprise: {{ entreprise.name }}</label
          >
        </div>
      </div>
      <input
        type="text"
        class="input-username"
        v-model="projectName"
        placeholder="Name"
      />
      <input
        type="text"
        class="input-username"
        v-model="projectLink"
        placeholder="Link (to a Git)"
      />
      <span class="input-username">Contributors</span>
      <div
        v-for="user in users"
        v-bind:key="user.address"
        class="input-username"
      >
        <input
          type="checkbox"
          :id="user.address"
          :value="user.address"
          v-model="contributors"
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
  name: 'CreateProject',
  components: { Card },
  setup() {
    const store = useStore()
    const address = computed(() => store.state.account.address)
    const contract = computed(() => store.state.contract)
    return { address, contract }
  },
  data() {
    const account = null
    const users: any[] = []
    const entreprise = null
    const project = null
    const projectName = ''
    const contributors: never[] = []
    const balance = ''
    const belongsToUser = 'true'
    const projectLink = ''
    return {
      account,
      users,
      entreprise,
      project,
      projectName,
      contributors,
      balance,
      belongsToUser,
      projectLink,
    }
  },
  methods: {
    async createProject() {
      const {
        contract,
        projectName,
        contributors,
        balance,
        belongsToUser,
        projectLink,
      } = this
      const name = projectName.trim().replace(/ /g, '_')
      await contract.methods
        .createProject(name, contributors, balance, belongsToUser, projectLink)
        .send()
      await this.$router.push({ name: 'Account' })
    },
  },
  async mounted() {
    const { address, contract } = this
    const account = await contract.methods.user(address).call()
    if (account.registered) this.account = account
    const entreprise = await contract.methods.entreprise(address).call()
    if (entreprise.name) this.entreprise = entreprise
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