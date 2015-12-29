package reflash.display2;

class ViewComponent implements Updatable {
    private var view:View;

    public function new(view:View) {
        this.view = view;
    }

    public function remove() {
        view.components.remove(this);
    }

    public function update(context:Update):Void {
    }
}
