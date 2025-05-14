import { Button } from '@packages/ui/components/ui/button';
import { createFileRoute } from '@tanstack/react-router';

export const Route = createFileRoute('/')({
	component: App,
});

function App() {
	return (
		<div className="bg-black h-screen w-screen flex flex-col gap-2 items-center justify-center">
			<h1 className="text-white">Hello world</h1>
			<Button className="text-white">Click me</Button>
		</div>
	);
}
