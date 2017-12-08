# Crowdsale

It is necessary to determine an addresses contract creation at a nonce that is 3 higher than it's current nonce in order to properly deploy these contracts.
After determininig the Token contract's address at the future nonce, deploy the presale and crowdsale with your chosen parameters.
Then you can deploy the Token contract with the addresses of the presale and crowdsale as only they can mint tokens.
