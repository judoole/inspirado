package no.inspirado {
public class VanillaObject {
    public var id:String;
    public var hasDoneInit:Boolean = false;
    public var hasInvokedMethodThatShouldNeverBeInvoked:Boolean = false;

    public function VanillaObject(id:String = "1") {
        this.id = id;
    }

    [Init]
    public function thisIsInit():void {
        hasDoneInit = true;
    }

    public function shouldNeverBeInvoked():void {
        hasInvokedMethodThatShouldNeverBeInvoked = true;
    }
}
}