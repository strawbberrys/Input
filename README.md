<div align="center">
    <h1>Input</h1>
    <p>A Roblox module for handling user input on the server.</p>
    <a href="https://input.pages.dev/"><strong>View docs</strong></a>
</div>
<!--moonwave-hide-before-this-line-->

## Why use this over [UserInputService](https://developer.roblox.com/en-us/api-reference/class/UserInputService)?

Well, it's simple. This module provides a server-side implementation for input management and more customizable features. 

### Why would you want to control inputs on the server?

- *Easier communication*: Lets say you want to check if the user pressed the "R" key on their keyboard to reload a weapon. Well before, you would have to connect to [UserInputService.InputBegan](https://developer.roblox.com/en-us/api-reference/event/UserInputService/InputBegan) on the client, then use a [RemoteEvent](https://developer.roblox.com/en-us/api-reference/class/RemoteEvent) to tell the server that the client wants to reload, then the server would finally be able to reload the weapon. With this module, you can completely cut out the middle man and have everything handeled on the server. That can mean cleaner and easier to understand code, and less client -> server communication.
- *Hide your code*: We all have had experience with exploiters, and we all know they are a parisite for our games. By using this module, you can prevent exploiters from being able to read your code which handles inputs. That means it can be harder for exploiters to abuse your game and find out how it works.

### What customizable features does this module contain?

As an example, if you want to add time-out in between key presses, you would have to create a custom function to get the time between each press. But now with this module, you can simply use [Input:setTimeout](). There are many other features which you would usually need to create customly, but with this module everything is laid out for you.